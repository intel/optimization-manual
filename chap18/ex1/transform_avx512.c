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

#include "transform_avx512.h"

void transform_avx512(float sin_theta, float cos_theta, float *in, float *out,
		      size_t len)
{
	// Static memory allocation of 16 floats with 64byte alignments

	// clang-format off

#ifdef _MSC_VER
	__declspec(align(64)) float cos_sin_theta_vec[16] = {
#else
	float cos_sin_theta_vec[16] __attribute__((aligned(64))) = {
#endif
		cos_theta, sin_theta, cos_theta, sin_theta,
		cos_theta, sin_theta, cos_theta, sin_theta,
		cos_theta, sin_theta, cos_theta, sin_theta,
		cos_theta, sin_theta, cos_theta, sin_theta
	};
#ifdef _MSC_VER
	__declspec(align(64)) float sin_cos_theta_vec[16] = {
#else
	float sin_cos_theta_vec[16] __attribute__((aligned(64))) = {
#endif
		sin_theta, cos_theta, sin_theta, cos_theta,
		sin_theta, cos_theta, sin_theta, cos_theta,
		sin_theta, cos_theta, sin_theta, cos_theta,
		sin_theta, cos_theta, sin_theta, cos_theta
	};

	// clang-format on

	//__m512 data type represents a zmm
	// register with 16 float elements
	__m512 zmm_cos_sin = _mm512_load_ps(cos_sin_theta_vec);

	// Intel® AVX-512 512bit packed single load
	__m512 zmm_sin_cos = _mm512_load_ps(sin_cos_theta_vec);
	__m512 zmm0, zmm1, zmm2, zmm3;
	// processing 32 elements in an unrolled
	// twice loop
	for (int i = 0; i < len; i += 32) {
		zmm0 = _mm512_load_ps(in + i);
		zmm1 = _mm512_moveldup_ps(zmm0);
		zmm2 = _mm512_movehdup_ps(zmm0);
		zmm2 = _mm512_mul_ps(zmm2, zmm_sin_cos);
		zmm3 = _mm512_fmaddsub_ps(zmm1, zmm_cos_sin, zmm2);
		_mm512_store_ps(out + i, zmm3);

		zmm0 = _mm512_load_ps(in + i + 16);
		zmm1 = _mm512_moveldup_ps(zmm0);
		zmm2 = _mm512_movehdup_ps(zmm0);
		zmm2 = _mm512_mul_ps(zmm2, zmm_sin_cos);
		zmm3 = _mm512_fmaddsub_ps(zmm1, zmm_cos_sin, zmm2);
		_mm512_store_ps(out + i + 16, zmm3);
	}
}

bool transform_avx512_check(float sin_theta, float cos_theta, float *in,
			    float *out, size_t len)
{
	/*
	 * in and out must be non NULL and 64 byte aligned.
	 */

	if (!in || !out)
		return false;

	if (((uintptr_t)in) % 64 != 0)
		return false;

	if (((uintptr_t)out) % 64 != 0)
		return false;

	/*
	 * len must be divisible by 32.
	 */

	if (len % 32 != 0)
		return false;

	transform_avx512(sin_theta, cos_theta, in, out, len);

	return true;
}
