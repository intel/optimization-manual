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

#include "embedded_rounding.h"
#include "manual_rounding.h"

#define MAX_ITERATIONS 1024

#ifdef _MSC_VER
__declspec(align(64)) static float a[16];
__declspec(align(64)) static float b[16];
__declspec(align(64)) static float out1[16];
__declspec(align(64)) static float out2[16];
#else
static float a[16] __attribute__((aligned(64)));
static float b[16] __attribute__((aligned(64)));
static float out1[16] __attribute__((aligned(64)));
static float out2[16] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < 16; i++) {
		a[i] = rand() / ((float)RAND_MAX);
		b[i] = rand() / ((float)RAND_MAX);
		out1[i] = 0.0;
		out2[i] = 0.0;
	}
}

TEST(avx512_16, embedded_rounding)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	for (size_t i = 0; i < MAX_ITERATIONS; i++) {
		init_sources();
		ASSERT_EQ(embedded_rounding_check(a, b, out1), true);
		ASSERT_EQ(manual_rounding_check(a, b, out2), true);
		for (size_t j = 0; j < 16; j++)
			ASSERT_EQ(out1[j], out2[j]);
	}

	ASSERT_EQ(embedded_rounding_check(NULL, b, out1), false);
	ASSERT_EQ(embedded_rounding_check(a, NULL, out1), false);
	ASSERT_EQ(embedded_rounding_check(a, b, NULL), false);
	ASSERT_EQ(manual_rounding_check(NULL, b, out2), false);
	ASSERT_EQ(manual_rounding_check(a, NULL, out2), false);
	ASSERT_EQ(manual_rounding_check(a, b, NULL), false);
}
