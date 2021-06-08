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

#include "mul_blend_avx.h"
#include "mul_blend_avx512.h"
#include "optimisation_common.h"

const size_t MAX_SIZE = 4096;

#ifdef _MSC_VER
__declspec(align(64)) static double a[MAX_SIZE];
__declspec(align(64)) static double b[MAX_SIZE];
__declspec(align(64)) static double c[MAX_SIZE];
#else
static double a[MAX_SIZE] __attribute__((aligned(64)));
static double b[MAX_SIZE] __attribute__((aligned(64)));
static double c[MAX_SIZE] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = (float)((i & 1) ? i : 0);
		b[i] = (float)i + 1;
		c[i] = 0.0;
	}
}

TEST(avx512_3, mul_blend_avx)
{
	init_sources();

	ASSERT_EQ(mul_blend_avx_check(a, b, c, MAX_SIZE), true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		double expected = (i & 1) ? b[i] * a[i] : b[i];
		ASSERT_DOUBLE_EQ(c[i], expected);
	}

	ASSERT_EQ(mul_blend_avx_check(NULL, b, c, MAX_SIZE), false);
	ASSERT_EQ(mul_blend_avx_check(a, NULL, c, MAX_SIZE), false);
	ASSERT_EQ(mul_blend_avx_check(a, b, NULL, MAX_SIZE), false);
	ASSERT_EQ(mul_blend_avx_check(a, b, c, MAX_SIZE - 8), false);
}

TEST(avx512_3, mul_blend_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	ASSERT_EQ(mul_blend_avx512_check(a, b, c, MAX_SIZE), true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		double expected = (i & 1) ? b[i] * a[i] : b[i];
		ASSERT_DOUBLE_EQ(c[i], expected);
	}

	ASSERT_EQ(mul_blend_avx512_check(NULL, b, c, MAX_SIZE), false);
	ASSERT_EQ(mul_blend_avx512_check(a, NULL, c, MAX_SIZE), false);
	ASSERT_EQ(mul_blend_avx512_check(a, b, NULL, MAX_SIZE), false);
	ASSERT_EQ(mul_blend_avx512_check(a, b, c, MAX_SIZE - 16), false);
}
