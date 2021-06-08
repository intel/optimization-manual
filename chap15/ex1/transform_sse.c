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

#include <immintrin.h>

#include "transform_sse.h"

void transform_sse(float sin_teta, float cos_teta, float *in, float *out,
		   size_t len)
{
	// Static memory allocation of 4 floats with 16byte alignment

	// clang-format off

#ifdef _MSC_VER // preferred VS2019 version 16.3 or higher
	__declspec(align(16)) float cos_sin_teta_vec[4] = {
		cos_teta, sin_teta, cos_teta, sin_teta};
	__declspec(align(16)) float sin_cos_teta_vec[4] = {
		sin_teta, cos_teta, sin_teta, cos_teta};
#else
	float cos_sin_teta_vec[4] __attribute__((aligned(16))) = {
		cos_teta, sin_teta, cos_teta, sin_teta};
	float sin_cos_teta_vec[4] __attribute__((aligned(16))) = {
		sin_teta, cos_teta, sin_teta, cos_teta};
#endif

	// clang-format on

	//__m128 data type represents an xmm
	// register with 4 float elements

	__m128 xmm_cos_sin = _mm_load_ps(cos_sin_teta_vec);

	// SSE 128bit packed single load

	__m128 xmm_sin_cos = _mm_load_ps(sin_cos_teta_vec);
	__m128 xmm0, xmm1, xmm2,
	    xmm3; // processing 8 elements in an unrolled twice loop
	for (int i = 0; i < len; i += 8) {
		xmm0 = _mm_load_ps(in + i);
		xmm1 = _mm_moveldup_ps(xmm0);
		xmm2 = _mm_movehdup_ps(xmm0);
		xmm1 = _mm_mul_ps(xmm1, xmm_cos_sin);
		xmm2 = _mm_mul_ps(xmm2, xmm_sin_cos);
		xmm3 = _mm_addsub_ps(xmm1, xmm2);
		_mm_store_ps(out + i, xmm3);
		xmm0 = _mm_load_ps(in + i + 4);
		xmm1 = _mm_moveldup_ps(xmm0);
		xmm2 = _mm_movehdup_ps(xmm0);
		xmm1 = _mm_mul_ps(xmm1, xmm_cos_sin);
		xmm2 = _mm_mul_ps(xmm2, xmm_sin_cos);
		xmm3 = _mm_addsub_ps(xmm1, xmm2);
		_mm_store_ps(out + i + 4, xmm3);
	}
}

bool transform_sse_check(float sin_teta, float cos_teta, float *in, float *out,
			 size_t len)
{
	/*
	 * in and out must be non NULL and 32 byte aligned.
	 */

	if (!in || !out)
		return false;

	if (((uintptr_t)in) % 16 != 0)
		return false;

	if (((uintptr_t)out) % 16 != 0)
		return false;

	/*
	 * len must be divisible by 8.
	 */

	if (len % 8 != 0)
		return false;

	transform_sse(sin_teta, cos_teta, in, out, len);

	return true;
}
