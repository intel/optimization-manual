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

TEST(avx512_1, transform_avx)
{
	int len = 3200;
	// Dynamic memory allocation with 32byte
	// alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 32);
	ASSERT_NE(pInVector, nullptr);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 32);
	ASSERT_NE(pOutVector, nullptr);
	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;
	float cos_theta = 0.8660254037f;
	float sin_theta = 0.5f;

	ASSERT_EQ(transform_avx_check(sin_theta, cos_theta, pInVector,
				      pOutVector, len),
		  true);

	for (int i = 0; i < len; i += 2) {
		// Assert X'
		float cosx = pInVector[i] * cos_theta;
		float siny = pInVector[i + 1] * sin_theta;
		ASSERT_FLOAT_EQ(cosx - siny, pOutVector[i]);
		// Assert Y'
		float sinx = pInVector[i] * sin_theta;
		float cosy = pInVector[i + 1] * cos_theta;
		ASSERT_FLOAT_EQ(sinx + cosy, pOutVector[i + 1]);
	}

	ASSERT_EQ(
	    transform_avx_check(sin_theta, cos_theta, NULL, pOutVector, len),
	    false);
	ASSERT_EQ(
	    transform_avx_check(sin_theta, cos_theta, pInVector, NULL, len),
	    false);
	ASSERT_EQ(transform_avx_check(sin_theta, cos_theta, pInVector + 1,
				      pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx_check(sin_theta, cos_theta, pInVector,
				      pOutVector + 1, len),
		  false);
	ASSERT_EQ(transform_avx_check(sin_theta, cos_theta, pInVector,
				      pOutVector, len - 4),
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}

TEST(avx512_1, transform_avx512)
{
	int len = 3200;
	// Dynamic memory allocation with 64byte
	// alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 64);
	ASSERT_NE(pInVector, nullptr);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 64);
	ASSERT_NE(pOutVector, nullptr);
	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;
	float cos_theta = 0.8660254037f;
	float sin_theta = 0.5f;

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	ASSERT_EQ(transform_avx512_check(sin_theta, cos_theta, pInVector,
					 pOutVector, len),
		  true);

	for (int i = 0; i < len; i += 2) {
		// Assert X'
		float cosx = pInVector[i] * cos_theta;
		float siny = pInVector[i + 1] * sin_theta;
		ASSERT_FLOAT_EQ(cosx - siny, pOutVector[i]);
		// Assert Y'
		float sinx = pInVector[i] * sin_theta;
		float cosy = pInVector[i + 1] * cos_theta;
		ASSERT_FLOAT_EQ(sinx + cosy, pOutVector[i + 1]);
	}

	ASSERT_EQ(
	    transform_avx512_check(sin_theta, cos_theta, NULL, pOutVector, len),
	    false);
	ASSERT_EQ(
	    transform_avx512_check(sin_theta, cos_theta, pInVector, NULL, len),
	    false);
	ASSERT_EQ(transform_avx512_check(sin_theta, cos_theta, pInVector + 1,
					 pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx512_check(sin_theta, cos_theta, pInVector,
					 pOutVector + 1, len),
		  false);
	ASSERT_EQ(transform_avx512_check(sin_theta, cos_theta, pInVector,
					 pOutVector, len - 16),
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}
