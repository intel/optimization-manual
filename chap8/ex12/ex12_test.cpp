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
#include "sigmoid_scalef_avx512.h"

static void init_data(float *input, float *expected)
{
	for (size_t i = 0; i < 16; i++)
		input[i] = std::rand() / ((float)RAND_MAX);

	for (size_t i = 0; i < 16; i++)
		expected[i] = 1.0f / (exp(-input[i]) + 1);
}

TEST(vnni, sigmoid_scalef)
{
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(64)) float input[16];
	__declspec(align(64)) float expected[16];
	__declspec(align(64)) float got[16];
#else
	float input[16] __attribute__((aligned(64)));
	float expected[16] __attribute__((aligned(64)));
	float got[16] __attribute__((aligned(64)));
#endif

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data(input, expected);

	sigmoid_scalef_avx512(input, got);

	for (size_t i = 0; i < 16; i++) {
		ASSERT_NEAR(expected[i], got[i], 0.01);
	}
}
