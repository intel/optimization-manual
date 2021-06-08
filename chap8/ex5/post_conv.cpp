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

#include "post_conv.hpp"

void basic_post_conv(uint32_t *output, int8_t *outputFeatureMaps,
		     size_t OFMChannelOffset, size_t offset, float *bias,
		     float *dqfs)
{
	__m512i in = _mm512_load_epi32(output);

	// dest points to a vector of 16 OFMSs belonging to the same pixel.
	uint8_t *dest = (uint8_t *)(outputFeatureMaps) + offset;

	// in are the 16 accumulators in int32 that we need to operate on.
	__m512 resf = _mm512_cvtepi32_ps(in); // Convert to float

	// add bias if there is one and then dequantize + requantize in a single
	// step
	if (bias) {
		resf = _mm512_fmadd_ps(
		    resf, _mm512_load_ps(dqfs + OFMChannelOffset),
		    _mm512_load_ps((__m512 *)(bias + OFMChannelOffset)));
	} else {
		resf = _mm512_mul_ps(resf,
				     _mm512_load_ps(dqfs + OFMChannelOffset));
	}

#if RELU
	resf = _mm512_max_ps(resf, broadcast_zero);
#endif

	// at this point we are in the uint8 range.
	__m512i res = _mm512_cvt_roundps_epi32(resf, _MM_FROUND_TO_NEAREST_INT |
							 _MM_FROUND_NO_EXC);
	__m128i res8;

#if ELTWISE
/* fused Eltwise ops */
#else
#if !RELU
	res = _mm512_add_epi32(res, _mm512_set1_epi32(128));
#endif
	res8 = _mm512_cvtusepi32_epi8(res);
#endif // ELTWISE

#if POOLING
/* fused pooling ops */
#endif

	_mm_store_si128((__m128i *)dest, res8);
}

void post_conv_scalar(uint32_t *output, int8_t *outputFeatureMaps,
		      size_t OFMChannelOffset, size_t offset, float *bias,
		      float *dqfs, int8_t *dest_scalar)
{
	__m512i in = _mm512_load_epi32(output);

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(64)) uint32_t out_buf[16];
#else
	uint32_t out_buf[16] __attribute__((aligned(64)));
#endif
	float resf[16];
	uint32_t res[16];

	_mm512_store_epi32(&out_buf[0], in);
	for (size_t i = 0; i < 16; i++)
		resf[i] = (float)out_buf[i];

	if (bias)
		for (size_t i = 0; i < 16; i++)
			resf[i] = (resf[i] * dqfs[OFMChannelOffset + i]) +
				  bias[OFMChannelOffset + i];
	else
		for (size_t i = 0; i < 16; i++)
			resf[i] *= dqfs[OFMChannelOffset + i];

#if RELU
	for (size_t i = 0; i < 16; i++)
		if (resf[i] < 0.0)
			resf[i] = 0.0;
#endif

	for (size_t i = 0; i < 16; i++) {
		__m128 rnd = _mm_set_ss(resf[i]);
		res[i] = (uint32_t)_mm_cvtss_f32(_mm_round_ss(
		    rnd, rnd, _MM_FROUND_TO_NEAREST_INT | _MM_FROUND_NO_EXC));
	}

#if !RELU
	for (size_t i = 0; i < 16; i++)
		res[i] += 128;
#endif

	for (size_t i = 0; i < 16; i++) {
		if (res[i] > 255)
			res[i] = 255;
		dest_scalar[i] = (uint8_t)res[i];
	}
}
