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

#include "transform_avx.h"
#include "transform_sse.h"

TEST(avx_1, transform_sse)
{
	int len = 3200;
	// Dynamic memory allocation with 16byte
	// alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 16);
	ASSERT_NE(pInVector, nullptr);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 16);
	ASSERT_NE(pOutVector, nullptr);
	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;
	float cos_teta = 0.8660254037f;
	float sin_teta = 0.5f;

	ASSERT_EQ(
	    transform_sse_check(sin_teta, cos_teta, pInVector, pOutVector, len),
	    true);

	for (int i = 0; i < len; i += 2) {
		if (i & 1) {
			float cosx = pInVector[i + 1] * cos_teta;
			float sinx = pInVector[i + 1] * sin_teta;
			ASSERT_FLOAT_EQ(sinx + cosx, pOutVector[i]);
		} else {
			float cosx = pInVector[i] * cos_teta;
			float sinx = pInVector[i] * sin_teta;
			ASSERT_FLOAT_EQ(cosx - sinx, pOutVector[i]);
		}
	}

	ASSERT_EQ(
	    transform_sse_check(sin_teta, cos_teta, NULL, pOutVector, len),
	    false);
	ASSERT_EQ(transform_sse_check(sin_teta, cos_teta, pInVector, NULL, len),
		  false);
	ASSERT_EQ(transform_sse_check(sin_teta, cos_teta, pInVector + 2,
				      pOutVector, len - 2),
		  false);
	ASSERT_EQ(transform_sse_check(sin_teta, cos_teta, pInVector,
				      pOutVector + 2, len - 2),
		  false);
	ASSERT_EQ(transform_sse_check(sin_teta, cos_teta, pInVector, pOutVector,
				      len) -
		      1,
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}

TEST(avx_1, transform_avx)
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
	float cos_teta = 0.8660254037f;
	float sin_teta = 0.5f;

	ASSERT_EQ(
	    transform_avx_check(sin_teta, cos_teta, pInVector, pOutVector, len),
	    true);

	for (int i = 0; i < len; i += 2) {
		if (i & 1) {
			float cosx = pInVector[i + 1] * cos_teta;
			float sinx = pInVector[i + 1] * sin_teta;
			ASSERT_FLOAT_EQ(sinx + cosx, pOutVector[i]);
		} else {
			float cosx = pInVector[i] * cos_teta;
			float sinx = pInVector[i] * sin_teta;
			ASSERT_FLOAT_EQ(cosx - sinx, pOutVector[i]);
		}
	}

	ASSERT_EQ(
	    transform_avx_check(sin_teta, cos_teta, NULL, pOutVector, len),
	    false);
	ASSERT_EQ(transform_avx_check(sin_teta, cos_teta, pInVector, NULL, len),
		  false);
	ASSERT_EQ(transform_avx_check(sin_teta, cos_teta, pInVector + 4,
				      pOutVector, len - 4),
		  false);
	ASSERT_EQ(transform_avx_check(sin_teta, cos_teta, pInVector,
				      pOutVector + 4, len - 4),
		  false);
	ASSERT_EQ(transform_avx_check(sin_teta, cos_teta, pInVector, pOutVector,
				      len) -
		      1,
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}
