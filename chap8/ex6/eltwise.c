/*
 * Copyright (C) 2021 by Intel Corporation
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#include "eltwise.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) uint8_t eltwise_data[16];
#else
uint8_t eltwise_data[16] __attribute__((aligned(64)));
#endif

static __m512 init_data(float *conv_qfactor, float *eltwise_qfactor)
{
	__m512 resf;
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(64)) uint32_t output[16];
#else
	uint32_t output[16] __attribute__((aligned(64)));
#endif
	uint32_t max = 1;
	float qfactor;
	__m512 qfactor_broadcast;

	for (size_t i = 0; i < 16; i++) {
		output[i] = rand() % INT_MAX;
		if (output[i] > max)
			max = output[i];
	}
	resf = _mm512_cvtepi32_ps(_mm512_load_epi32(&output[0]));
	qfactor = 255.0f / max;
	qfactor_broadcast = _mm512_set1_ps(qfactor);
	resf = _mm512_mul_ps(resf, qfactor_broadcast);
	*conv_qfactor = qfactor;

	for (size_t i = 0; i < 16; i++) {
		output[i] = rand() % INT_MAX;
		if (output[i] > max)
			max = output[i];
	}

	qfactor = 255.0f / max;
	*eltwise_qfactor = qfactor;

	for (size_t i = 0; i < 16; i++)
		eltwise_data[i] = (uint8_t)(output[i] * qfactor);

	return resf;
}

static __m128i eltwise_scalar(__m512 resf, uint8_t *eltwise_data,
			      float next_qfactor, float eltwise_dqfactor,
			      size_t ew_offset, bool signed_residual, bool relu)
{
	int32_t eltwise_i32[16];
	float eltwise_f32[16];
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(64)) float resf_f32[16];
	__declspec(align(64)) int8_t res8[16];
#else
	float resf_f32[16] __attribute__((aligned(64)));
	int8_t res8[16] __attribute__((aligned(64)));
#endif
	float qfactor = next_qfactor * eltwise_dqfactor;

	_mm512_store_ps(resf_f32, resf);

	for (size_t i = 0; i < 16; i++)
		eltwise_i32[i] = (int32_t)eltwise_data[i + ew_offset];

	if (signed_residual) {
		for (size_t i = 0; i < 16; i++)
			eltwise_i32[i] -= 128;
	}

	for (size_t i = 0; i < 16; i++) {
		eltwise_f32[i] =
		    (((float)eltwise_i32[i]) + resf_f32[i]) * qfactor;
	}

	if (relu)
		for (size_t i = 0; i < 16; i++)
			if (eltwise_f32[i] < 0)
				eltwise_f32[i] = 0;

	for (size_t i = 0; i < 16; i++) {
		__m128 rnd = _mm_set_ss(eltwise_f32[i]);
		uint32_t val = (uint32_t)_mm_cvtss_f32(_mm_round_ss(
		    rnd, rnd, _MM_FROUND_TO_NEAREST_INT | _MM_FROUND_NO_EXC));
		if (val > 255)
			val = 255;

		res8[i] = (int8_t)val;
	}

	if (!relu)
		for (size_t i = 0; i < 16; i++)
			res8[i] -= 128;

	return _mm_load_si128((__m128i const *)res8);
}

__m128i eltwise(__m512 resf, uint8_t *eltwise_data, float next_qfactor,
		float eltwise_dqfactor, size_t ew_offset, bool signed_residual,
		bool relu)
{
	__m128i res8;
	__m512 broadcast_zero = _mm512_set1_ps(0);
	__m512i broadcast_128 = _mm512_set1_epi32(128);
	__m128i eltwise_u8 =
	    _mm_load_si128((const __m128i *)(eltwise_data + ew_offset));
	__m512i eltwise_i32 = _mm512_cvtepu8_epi32(eltwise_u8);
	__m512 nqf = _mm512_set1_ps(next_qfactor);
	__m512 edqf = _mm512_set1_ps(eltwise_dqfactor);
	__m512 broadcast_fused_eltwise_out_qfactor = _mm512_mul_ps(nqf, edqf);

	if (signed_residual)
		eltwise_i32 = _mm512_sub_epi32(eltwise_i32, broadcast_128);

	__m512 eltwise_f32 = _mm512_cvtepi32_ps(eltwise_i32);

	resf = _mm512_add_ps(eltwise_f32, resf); /* add with conv results */

	/* dequantization and then requantization to next layer in one op */

	resf = _mm512_mul_ps(resf, broadcast_fused_eltwise_out_qfactor);

	if (relu)
		resf = _mm512_max_ps(resf, broadcast_zero);

	__m512i data_i32 = _mm512_cvt_roundps_epi32(
	    resf, (_MM_FROUND_TO_NEAREST_INT | _MM_FROUND_NO_EXC));

	res8 = _mm512_cvtusepi32_epi8(data_i32);
	if (!relu)
		res8 =
		    _mm_add_epi8(res8, _mm_set1_epi8(-128)); // hack to add 128

	return res8;
}

void test_eltwise(int8_t *res8s, int8_t *res8v)
{
	float conv_qfactor, eltwise_qfactor;

	__m512 resf = init_data(&conv_qfactor, &eltwise_qfactor);
	__m128i v = eltwise(resf, eltwise_data, conv_qfactor, eltwise_qfactor,
			    0, false, true);
	_mm_store_si128((__m128i *)&res8v[0], v);

	__m128i s = eltwise_scalar(resf, eltwise_data, conv_qfactor,
				   eltwise_qfactor, 0, false, true);
	_mm_store_si128((__m128i *)&res8s[0], s);
}
