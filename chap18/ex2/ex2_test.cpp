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

#include <xmmintrin.h>

#include "gtest/gtest.h"

#include "optimisation_common.h"
#include "transform_avx.h"
#include "transform_avx512.h"

TEST(avx512_2, transform_avx)
{
	int len = 3200;
	// Dynamic memory allocation with 32byte alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 32);
	ASSERT_NE(pInVector, nullptr);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 32);
	ASSERT_NE(pOutVector, nullptr);

	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;

	float cos_teta = 0.8660254037f;
	float sin_teta = 0.5f;

	// clang-format off

	//Static memory allocation of 8 floats with 32byte alignments
#ifdef _MSC_VER
	__declspec(align(32)) float cos_sin_teta_vec[8] = {
#else
	float cos_sin_teta_vec[8] __attribute__((aligned(32))) = {
#endif
            cos_teta, sin_teta, cos_teta, sin_teta,
            cos_teta, sin_teta, cos_teta, sin_teta
        };
#ifdef _MSC_VER
	__declspec(align(32)) float sin_cos_teta_vec[8] = {
#else
	float sin_cos_teta_vec[8] __attribute__((aligned(32))) = {
#endif
            sin_teta, cos_teta, sin_teta, cos_teta,
            sin_teta, cos_teta, sin_teta, cos_teta
        };

	// clang-format on

	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, pOutVector, len),
		  true);

	for (int i = 0; i < len; i += 2) {
		if (i & 1) {
			float cosx = pInVector[i + 1] * cos_teta;
			float sinx = pInVector[i + 1] * sin_teta;
			EXPECT_FLOAT_EQ(sinx + cosx, pOutVector[i]);
		} else {
			float cosx = pInVector[i] * cos_teta;
			float sinx = pInVector[i] * sin_teta;
			EXPECT_FLOAT_EQ(cosx - sinx, pOutVector[i]);
		}
	}

	ASSERT_EQ(transform_avx_check(NULL, sin_cos_teta_vec, pInVector,
				      pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, NULL, pInVector,
				      pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec, NULL,
				      pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, NULL, len),
		  false);
	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, pOutVector + 4, len),
		  false);
	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, pOutVector, len + 8),
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}

TEST(avx512_2, transform_avx512)
{
	int len = 3200;
	// Dynamic memory allocation with 64byte alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 64);
	ASSERT_NE(pInVector, nullptr);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 64);
	ASSERT_NE(pOutVector, nullptr);

	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;

	float cos_teta = 0.8660254037f;
	float sin_teta = 0.5f;

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

		// clang-format off

	//Static memory allocation of 16 floats with 64byte align- ments
#ifdef _MSC_VER
	__declspec(align(64)) float cos_sin_teta_vec[16] = {
#else
	float cos_sin_teta_vec[16] __attribute__((aligned(64))) = {
#endif
            cos_teta, sin_teta, cos_teta, sin_teta,
            cos_teta, sin_teta, cos_teta, sin_teta,
            cos_teta, sin_teta, cos_teta, sin_teta,
            cos_teta, sin_teta, cos_teta, sin_teta
        };
#ifdef _MSC_VER
	__declspec(align(64)) float sin_cos_teta_vec[16] = {
#else
	float sin_cos_teta_vec[16] __attribute__((aligned(64))) = {
#endif
            sin_teta, cos_teta, sin_teta, cos_teta,
            sin_teta, cos_teta, sin_teta, cos_teta,
            sin_teta, cos_teta, sin_teta, cos_teta,
            sin_teta, cos_teta, sin_teta, cos_teta
        };

	// clang-format on

	ASSERT_EQ(transform_avx512_check(cos_sin_teta_vec, sin_cos_teta_vec,
					 pInVector, pOutVector, len),
		  true);

	for (int i = 0; i < len; i += 2) {
		if (i & 1) {
			float cosx = pInVector[i + 1] * cos_teta;
			float sinx = pInVector[i + 1] * sin_teta;
			EXPECT_FLOAT_EQ(sinx + cosx, pOutVector[i]);
		} else {
			float cosx = pInVector[i] * cos_teta;
			float sinx = pInVector[i] * sin_teta;
			EXPECT_FLOAT_EQ(cosx - sinx, pOutVector[i]);
		}
	}

	ASSERT_EQ(transform_avx512_check(NULL, sin_cos_teta_vec, pInVector,
					 pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx512_check(cos_sin_teta_vec, NULL, pInVector,
					 pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx512_check(cos_sin_teta_vec, sin_cos_teta_vec,
					 NULL, pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx512_check(cos_sin_teta_vec, sin_cos_teta_vec,
					 pInVector, NULL, len),
		  false);
	ASSERT_EQ(transform_avx512_check(cos_sin_teta_vec, sin_cos_teta_vec,
					 pInVector, pOutVector + 8, len),
		  false);
	ASSERT_EQ(transform_avx512_check(cos_sin_teta_vec, sin_cos_teta_vec,
					 pInVector, pOutVector, len + 16),
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}
