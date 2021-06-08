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

#include "optimisation_common.h"
#include "single_rcps_14.h"
#include "single_rcps_22.h"
#include "single_rcps_23.h"

static float out_expected[16];

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static float in[16];
__declspec(align(64)) static float out[16];
#else
static float in[16] __attribute__((aligned(64)));
static float out[16] __attribute__((aligned(64)));
#endif

static void init_data()
{
	for (size_t i = 0; i < 16; i++) {
		in[i] = i + 1.0f;
		out_expected[i] = 1.0f / sqrtf(in[i]);
	}
}

TEST(avx512_31, single_rcps_22)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	memset(out, 0, sizeof(out));
	ASSERT_EQ(single_rcps_22_check(in, out), true);
	for (int i = 0; i < 16; i++) {
		ASSERT_FLOAT_EQ(out[i], out_expected[i]);
	}
	ASSERT_EQ(single_rcps_22_check(in, NULL), false);
	ASSERT_EQ(single_rcps_22_check(NULL, out), false);
}

TEST(avx512_31, single_rcps_23)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	memset(out, 0, sizeof(out));
	ASSERT_EQ(single_rcps_23_check(in, out), true);
	for (int i = 0; i < 16; i++) {
		ASSERT_FLOAT_EQ(out[i], out_expected[i]);
	}
	ASSERT_EQ(single_rcps_23_check(NULL, out), false);
	ASSERT_EQ(single_rcps_23_check(in, NULL), false);
}

TEST(avx512_31, single_rcps_14)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	memset(out, 0, sizeof(out));
	ASSERT_EQ(single_rcps_14_check(in, out), true);
	for (int i = 0; i < 16; i++) {
		ASSERT_NEAR(out[i], out_expected[i], 0.0001);
	}
	ASSERT_EQ(single_rcps_14_check(NULL, out), false);
	ASSERT_EQ(single_rcps_14_check(in, NULL), false);
}
