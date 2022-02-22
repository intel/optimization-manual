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

#include "gtest/gtest.h"

#include "halfp.h"
#include "singlep.h"

const int MAX_SIZE = 24; /* Must divisible by 8 */

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float x[MAX_SIZE + 8];
__declspec(align(32)) static float y[MAX_SIZE];

__declspec(align(16)) static __m128i xh[(MAX_SIZE / 8) + 1];
__declspec(align(16)) static __m128i yh[MAX_SIZE / 8];
#else
static float x[MAX_SIZE] __attribute__((aligned(32)));
static float y[MAX_SIZE] __attribute__((aligned(32)));

static __m128i xh[MAX_SIZE / 8] __attribute__((aligned(16)));
static __m128i yh[MAX_SIZE / 8] __attribute__((aligned(16)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		x[i] = i * 1.0f;
		y[i] = 0.0f;
	}
}

TEST(avx_34, singlep)
{
	init_sources();
	ASSERT_EQ(singlep_check(x, y, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE - 2; i++) {
		ASSERT_FLOAT_EQ(y[i], i + 1.0f);
	}
	ASSERT_EQ(singlep_check(NULL, y, MAX_SIZE), false);
	ASSERT_EQ(singlep_check(x, NULL, MAX_SIZE), false);
	ASSERT_EQ(singlep_check(x + 1, y, MAX_SIZE - 8), false);
	ASSERT_EQ(singlep_check(x, y + 1, MAX_SIZE - 8), false);
	ASSERT_EQ(singlep_check(x, y, MAX_SIZE - 4), false);
	ASSERT_EQ(singlep_check(x, y, 0), false);
}

TEST(avx_34, halfp)
{
	init_sources();
	memset(xh, 0, sizeof(xh));
	memset(yh, 0, sizeof(yh));

	/*  We need to initialise xh using intrinsics */

	for (size_t i = 0; i < MAX_SIZE / 8; i++) {
		__m256 a = _mm256_loadu_ps(&x[i * 8]);
		__m128i ah = _mm256_cvtps_ph(a, _MM_FROUND_TO_NEAREST_INT);
		_mm_store_si128(&xh[i], ah);
	}

	ASSERT_EQ(halfp_check(xh, yh, MAX_SIZE), true);

	/* Convert yh to y for verification */

	for (size_t i = 0; i < MAX_SIZE / 8; i++) {
		__m128i ah = _mm_load_si128(&yh[i]);
		__m256 a = _mm256_cvtph_ps(ah);
		_mm256_store_ps(&y[i * 8], a);
	}

	for (size_t i = 0; i < MAX_SIZE - 2; i++) {
		ASSERT_FLOAT_EQ(y[i], i + 1.0f);
	}

	ASSERT_EQ(halfp_check(NULL, yh, MAX_SIZE), false);
	ASSERT_EQ(halfp_check(xh, NULL, MAX_SIZE), false);
	ASSERT_EQ(halfp_check(xh, yh, MAX_SIZE - 4), false);
	ASSERT_EQ(halfp_check(xh, yh, 0), false);
}
