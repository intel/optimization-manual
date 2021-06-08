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

#include "transform_avx.h"

void transform_avx(float sin_teta, float cos_teta, float *in, float *out,
		   size_t len)
{
	// Static memory allocation of 8 floats with 32byte alignment

	// clang-format off

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(32)) float cos_sin_teta_vec[8] = {
#else
	float cos_sin_teta_vec[8] __attribute__((aligned(32))) = {
#endif
		cos_teta, sin_teta, cos_teta, sin_teta,
		cos_teta, sin_teta, cos_teta, sin_teta};
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(32)) float sin_cos_teta_vec[8] = {
#else
	float sin_cos_teta_vec[8] __attribute__((aligned(32))) = {
#endif
		sin_teta, cos_teta, sin_teta, cos_teta,
		sin_teta, cos_teta, sin_teta, cos_teta};

	//__m256 data type holds 8 float elements

	// clang-format on

	__m256 ymm_cos_sin = _mm256_load_ps(cos_sin_teta_vec);
	// AVX 256bit packed single load
	__m256 ymm_sin_cos = _mm256_load_ps(sin_cos_teta_vec);
	__m256 ymm0, ymm1, ymm2, ymm3;
	// processing 8 elements in an unrolled twice loop
	for (int i = 0; i < len; i += 16) {
		ymm0 = _mm256_load_ps(in + i);
		ymm1 = _mm256_moveldup_ps(ymm0);
		ymm2 = _mm256_movehdup_ps(ymm0);
		ymm1 = _mm256_mul_ps(ymm1, ymm_cos_sin);
		ymm2 = _mm256_mul_ps(ymm2, ymm_sin_cos);
		ymm3 = _mm256_addsub_ps(ymm1, ymm2);
		_mm256_store_ps(out + i, ymm3);
		ymm0 = _mm256_load_ps(in + i + 8);
		ymm1 = _mm256_moveldup_ps(ymm0);
		ymm2 = _mm256_movehdup_ps(ymm0);
		ymm1 = _mm256_mul_ps(ymm1, ymm_cos_sin);
		ymm2 = _mm256_mul_ps(ymm2, ymm_sin_cos);
		ymm3 = _mm256_addsub_ps(ymm1, ymm2);
		_mm256_store_ps(out + i + 8, ymm3);
	}
}

bool transform_avx_check(float sin_teta, float cos_teta, float *in, float *out,
			 size_t len)
{
	/*
	 * in and out must be non NULL and 32 byte aligned.
	 */

	if (!in || !out)
		return false;

	if (((uintptr_t)in) % 32 != 0)
		return false;

	if (((uintptr_t)out) % 32 != 0)
		return false;

	/*
	 * len must be divisible by 16.
	 */

	if (len % 16 != 0)
		return false;

	transform_avx(sin_teta, cos_teta, in, out, len);

	return true;
}
