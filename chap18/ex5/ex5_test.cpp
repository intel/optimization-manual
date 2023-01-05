/*
 * Copyright (C) 2022 by Intel Corporation
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

#include "mul_mask_avx512.h"
#include "mul_nomask_avx512.h"
#include "mul_zeromask_avx512.h"
#include "optimisation_common.h"

const size_t MAX_SIZE = 16;
const int ITERATIONS = 10;

#ifdef _MSC_VER
__declspec(align(32)) static float a[MAX_SIZE];
__declspec(align(32)) static float b[MAX_SIZE];
__declspec(align(32)) static float out1[MAX_SIZE];
__declspec(align(32)) static float out2[MAX_SIZE];
#else
static float a[MAX_SIZE] __attribute__((aligned(32)));
static float b[MAX_SIZE] __attribute__((aligned(32)));
static float out1[MAX_SIZE] __attribute__((aligned(32)));
static float out2[MAX_SIZE] __attribute__((aligned(32)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = (float)i;
		b[i] = 2.0;
		out1[i] = 1.0;
		out2[i] = 1.0;
	}
}

TEST(avx512_5, mul_nomask_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	ASSERT_EQ(mul_nomask_avx512_check(a, b, out1, out2, ITERATIONS), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		float expected = i * 2.0;
		ASSERT_FLOAT_EQ(out1[i], expected);
		ASSERT_FLOAT_EQ(out2[i], expected);
	}

	ASSERT_EQ(mul_nomask_avx512_check(NULL, b, out1, out2, ITERATIONS),
		  false);
	ASSERT_EQ(mul_nomask_avx512_check(a, NULL, out1, out2, ITERATIONS),
		  false);
	ASSERT_EQ(mul_nomask_avx512_check(a, b, NULL, out2, ITERATIONS), false);
	ASSERT_EQ(mul_nomask_avx512_check(a, b, out1, NULL, ITERATIONS), false);
	ASSERT_EQ(mul_nomask_avx512_check(a, b, out1, out2, 0), false);
}

TEST(avx512_5, mul_mask_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	ASSERT_EQ(mul_mask_avx512_check(a, b, out1, out2, ITERATIONS), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		// Odd indexes remains as 1.0
		float expected = 1.0;
		// Even indexes include masked values.
		if (i % 2 == 0) {
			expected = i * 2.0;
		}
		ASSERT_FLOAT_EQ(out1[i], expected);
		ASSERT_FLOAT_EQ(out2[i], expected);
	}

	ASSERT_EQ(mul_mask_avx512_check(NULL, b, out1, out2, ITERATIONS),
		  false);
	ASSERT_EQ(mul_mask_avx512_check(a, NULL, out1, out2, ITERATIONS),
		  false);
	ASSERT_EQ(mul_mask_avx512_check(a, b, NULL, out2, ITERATIONS), false);
	ASSERT_EQ(mul_mask_avx512_check(a, b, out1, NULL, ITERATIONS), false);
	ASSERT_EQ(mul_mask_avx512_check(a, b, out1, out2, 0), false);
}

TEST(avx512_5, mul_zeromask_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	ASSERT_EQ(mul_zeromask_avx512_check(a, b, out1, out2, ITERATIONS),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		// Odd indexes are mask as 0.0
		float expected = 0.0;
		// Even indexes include masked values.
		if (i % 2 == 0) {
			expected = i * 2.0;
		}
		ASSERT_FLOAT_EQ(out1[i], expected);
		ASSERT_FLOAT_EQ(out2[i], expected);
	}

	ASSERT_EQ(mul_zeromask_avx512_check(NULL, b, out1, out2, ITERATIONS),
		  false);
	ASSERT_EQ(mul_zeromask_avx512_check(a, NULL, out1, out2, ITERATIONS),
		  false);
	ASSERT_EQ(mul_zeromask_avx512_check(a, b, NULL, out2, ITERATIONS),
		  false);
	ASSERT_EQ(mul_zeromask_avx512_check(a, b, out1, NULL, ITERATIONS),
		  false);
	ASSERT_EQ(mul_zeromask_avx512_check(a, b, out1, out2, 0), false);
}
