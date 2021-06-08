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

#include <math.h>

#include "sqrt_rsqrtps_sse.h"
#include "sqrt_vrsqrtps_avx.h"

const int MAX_SIZE = 24; /* Must divisible by 8 */

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float x[MAX_SIZE];
__declspec(align(32)) static float y[MAX_SIZE];
#else
static float x[MAX_SIZE] __attribute__((aligned(32)));
static float y[MAX_SIZE] __attribute__((aligned(32)));
#endif

void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		x[i] = i * 1.0f;
		y[i] = 0.0f;
	}
}

TEST(avx_29, sqrt_rsqrtps_sse)
{
	init_sources();
	ASSERT_EQ(sqrt_rsqrtps_sse_check(x, y, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_NEAR(sqrt(x[i]), y[i], 0.01);
	}
	ASSERT_EQ(sqrt_rsqrtps_sse_check(NULL, y, MAX_SIZE), false);
	ASSERT_EQ(sqrt_rsqrtps_sse_check(x, NULL, MAX_SIZE), false);
	ASSERT_EQ(sqrt_rsqrtps_sse_check(x, y, MAX_SIZE + 2), false);
	ASSERT_EQ(sqrt_rsqrtps_sse_check(x, y, 0), false);
}

TEST(avx_29, sqrt_vrsqrtps_avx)
{
	init_sources();
	ASSERT_EQ(sqrt_vrsqrtps_avx_check(x, y, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_NEAR(sqrt(x[i]), y[i], 0.01);
	}
	ASSERT_EQ(sqrt_vrsqrtps_avx_check(NULL, y, MAX_SIZE), false);
	ASSERT_EQ(sqrt_vrsqrtps_avx_check(x, NULL, MAX_SIZE), false);
	ASSERT_EQ(sqrt_vrsqrtps_avx_check(x, y, MAX_SIZE + 4), false);
	ASSERT_EQ(sqrt_vrsqrtps_avx_check(x, y, 0), false);
}
