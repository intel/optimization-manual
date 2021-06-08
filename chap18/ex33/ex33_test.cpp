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

#include "double_div_14.h"
#include "double_div_26.h"
#include "double_div_52.h"
#include "double_div_53.h"
#include "optimisation_common.h"

static double out_expected[8];

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static double in1[8];
__declspec(align(64)) static double in2[8];
__declspec(align(64)) static double out[8];
#else
static double in1[8] __attribute__((aligned(64)));
static double in2[8] __attribute__((aligned(64)));
static double out[8] __attribute__((aligned(64)));
#endif

static void init_data()
{
	for (size_t i = 0; i < 8; i++) {
		in1[i] = 1;
		in2[i] = i + 1.0;
		out_expected[i] = in1[i] / in2[i];
	}
}

TEST(avx512_33, double_div_53)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	memset(out, 0, sizeof(out));
	ASSERT_EQ(double_div_53_check(in1, in2, out), true);
	for (int i = 0; i < 8; i++) {
		ASSERT_DOUBLE_EQ(out[i], out_expected[i]);
	}
	ASSERT_EQ(double_div_53_check(NULL, in2, out), false);
	ASSERT_EQ(double_div_53_check(in1, NULL, out), false);
	ASSERT_EQ(double_div_53_check(in1, in2, NULL), false);
}

TEST(avx512_33, double_div_52)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	memset(out, 0, sizeof(out));
	ASSERT_EQ(double_div_52_check(in1, in2, out), true);
	for (int i = 0; i < 8; i++) {
		ASSERT_DOUBLE_EQ(out[i], out_expected[i]);
	}
	ASSERT_EQ(double_div_52_check(NULL, in2, out), false);
	ASSERT_EQ(double_div_52_check(in1, NULL, out), false);
	ASSERT_EQ(double_div_52_check(in1, in2, NULL), false);
}

TEST(avx512_33, double_div_26)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	memset(out, 0, sizeof(out));
	ASSERT_EQ(double_div_26_check(in1, in2, out), true);
	for (int i = 0; i < 8; i++) {
		ASSERT_NEAR(out[i], out_expected[i], 0.00001);
	}
	ASSERT_EQ(double_div_26_check(NULL, in2, out), false);
	ASSERT_EQ(double_div_26_check(in1, NULL, out), false);
	ASSERT_EQ(double_div_26_check(in1, in2, NULL), false);
}

TEST(avx512_33, double_div_14)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	memset(out, 0, sizeof(out));
	ASSERT_EQ(double_div_14_check(in1, in2, out), true);
	for (int i = 0; i < 8; i++) {
		ASSERT_NEAR(out[i], out_expected[i], 0.00001);
	}
	ASSERT_EQ(double_div_14_check(NULL, in2, out), false);
	ASSERT_EQ(double_div_14_check(in1, NULL, out), false);
	ASSERT_EQ(double_div_14_check(in1, in2, NULL), false);
}
