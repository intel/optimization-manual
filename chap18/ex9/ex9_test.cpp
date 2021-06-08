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

#include "no_peeling.h"
#include "optimisation_common.h"
#include "peeling.h"

const size_t MAX_SIZE = 4096;

#ifdef _MSC_VER
__declspec(align(64)) static float in_image[MAX_SIZE];
__declspec(align(64)) static float c_image[MAX_SIZE];
__declspec(align(64)) static float asm_image[MAX_SIZE + 16];
#else
static float in_image[MAX_SIZE] __attribute__((aligned(64)));
static float c_image[MAX_SIZE] __attribute__((aligned(64)));
static float asm_image[MAX_SIZE + 16] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++)
		in_image[i] = static_cast<float>(i);
}

static void scalar(float *out, const float *in, size_t len, float add_value,
		   float alfa)
{
	for (size_t i = 0; i < len; i++)
		out[i] = (in[i] * alfa) + add_value;
}

TEST(avx512_9, no_peeling)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	scalar(c_image, in_image, MAX_SIZE, 2.0, 1.0);
	memset(asm_image, 0, sizeof(asm_image));
	ASSERT_EQ(no_peeling_check(asm_image, in_image, MAX_SIZE, 2.0, 1.0),
		  true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(c_image[i], asm_image[i]);
	}

	ASSERT_EQ(no_peeling_check(NULL, in_image, MAX_SIZE, 2.0, 1.0), false);
	ASSERT_EQ(no_peeling_check(asm_image, NULL, MAX_SIZE, 2.0, 1.0), false);
	ASSERT_EQ(no_peeling_check(asm_image, in_image, MAX_SIZE - 4, 2.0, 1.0),
		  false);
}

TEST(avx512_9, peeling)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	scalar(c_image, in_image, MAX_SIZE, 2.0, 1.0);

	for (size_t j = 0; j < 15; j++) {
		memset(asm_image, 0, sizeof(asm_image));
		ASSERT_EQ(
		    peel_check(asm_image + j, in_image, MAX_SIZE, 2.0, 1.0),
		    true);
		for (size_t i = 0; i < MAX_SIZE; i++) {
			ASSERT_EQ(c_image[i], asm_image[i + j]);
		}
	}

	ASSERT_EQ(peel_check(asm_image, in_image, 0, 2.0, 1.0), true);
	ASSERT_EQ(peel_check(NULL, NULL, 0, 2.0, 1.0), true);
	ASSERT_EQ(peel_check(NULL, NULL, MAX_SIZE, 2.0, 1.0), false);
}
