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

#include "three_tap_mixed_avx.h"

const int MAX_SIZE = 1026; /* Algorithm expects two trailing elements */

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float a[MAX_SIZE + 2];
__declspec(align(32)) static float coeff[3];
__declspec(align(32)) static float out[MAX_SIZE];
#else
static float a[MAX_SIZE + 2] __attribute__((aligned(32)));
static float coeff[3] __attribute__((aligned(32)));
static float out[MAX_SIZE] __attribute__((aligned(32)));
#endif

static void init_sources()
{
	coeff[0] = 1;
	coeff[1] = 3;
	coeff[2] = 7;
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = (float)i;
		out[i] = 0.0;
	}
}

TEST(avx_18, three_tap_mixed_avx)
{
	init_sources();
	ASSERT_EQ(three_tap_mixed_avx_check(a, coeff, out, MAX_SIZE - 2), true);
	for (size_t i = 0; i < MAX_SIZE - 2; i++) {
		float expected =
		    a[i] * coeff[0] + a[i + 1] * coeff[1] + a[i + 2] * coeff[2];
		ASSERT_FLOAT_EQ(expected, out[i]);
	}
	ASSERT_EQ(three_tap_mixed_avx_check(a, coeff, out, MAX_SIZE), false);
	ASSERT_EQ(three_tap_mixed_avx_check(NULL, coeff, out, MAX_SIZE - 2),
		  false);
	ASSERT_EQ(three_tap_mixed_avx_check(a, NULL, out, MAX_SIZE - 2), false);
	ASSERT_EQ(three_tap_mixed_avx_check(a, coeff, NULL, MAX_SIZE - 2),
		  false);
	ASSERT_EQ(three_tap_mixed_avx_check(a + 1, coeff, out, MAX_SIZE - 2),
		  false);
	ASSERT_EQ(three_tap_mixed_avx_check(a, coeff, out + 1, MAX_SIZE - 2),
		  false);
}
