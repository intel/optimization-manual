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

TEST(avx_2, transform_sse)
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

	// clang-format off

	// Static memory allocation of 4 floats with 16byte alignment
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
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

	ASSERT_EQ(transform_sse_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, pOutVector, len),
		  true);
	;
	for (int i = 0; i + 1 < len; i += 2) {
		// Assert X'
		float cosx = pInVector[i] * cos_teta;
		float siny = pInVector[i + 1] * sin_teta;
		ASSERT_FLOAT_EQ(cosx - siny, pOutVector[i]);
		// Assert Y'
		float sinx = pInVector[i] * sin_teta;
		float cosy = pInVector[i + 1] * cos_teta;
		ASSERT_FLOAT_EQ(sinx + cosy, pOutVector[i + 1]);
	}

	ASSERT_EQ(transform_sse_check(cos_sin_teta_vec, sin_cos_teta_vec, NULL,
				      pOutVector, len),
		  false);
	ASSERT_EQ(transform_sse_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, NULL, len),
		  false);
	ASSERT_EQ(transform_sse_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, pOutVector, len) -
		      1,
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}

TEST(avx_2, transform_avx)
{
	int len = 3200;
	// Dynamic memory allocation with 16byte
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

	// clang-format on

	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, pOutVector, len),
		  true);

	for (int i = 0; i + 1 < len; i += 2) {
		// Assert X'
		float cosx = pInVector[i] * cos_teta;
		float siny = pInVector[i + 1] * sin_teta;
		ASSERT_FLOAT_EQ(cosx - siny, pOutVector[i]);
		// Assert Y'
		float sinx = pInVector[i] * sin_teta;
		float cosy = pInVector[i + 1] * cos_teta;
		ASSERT_FLOAT_EQ(sinx + cosy, pOutVector[i + 1]);
	}

	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec, NULL,
				      pOutVector, len),
		  false);
	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, NULL, len),
		  false);
	ASSERT_EQ(transform_avx_check(cos_sin_teta_vec, sin_cos_teta_vec,
				      pInVector, pOutVector, len) -
		      1,
		  false);

	_mm_free(pInVector);
	_mm_free(pOutVector);
}
