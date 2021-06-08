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

#include "blend_avx512.h"
#include "mask_avx512.h"
#include "optimisation_common.h"

const size_t MAX_SIZE = 4096;

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t a[MAX_SIZE];
__declspec(align(64)) static uint32_t b[MAX_SIZE];
__declspec(align(64)) static uint32_t c[MAX_SIZE];
#else
static uint32_t a[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t b[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t c[MAX_SIZE] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (uint32_t i = 0; i < MAX_SIZE; i++) {
		b[i] = i;
		a[i] = i & 1;
		c[i] = 0;
	}
}

TEST(avx512_6, mask_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	ASSERT_EQ(mask_avx512_check(b, a, c, MAX_SIZE), true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		if (i & 1)
			ASSERT_EQ(c[i], b[i] * 2);
		else
			ASSERT_EQ(c[i], b[i] / 2);
	}

	ASSERT_EQ(mask_avx512_check(NULL, a, c, MAX_SIZE), false);
	ASSERT_EQ(mask_avx512_check(b, NULL, c, MAX_SIZE), false);
	ASSERT_EQ(mask_avx512_check(b, a, NULL, MAX_SIZE), false);
	ASSERT_EQ(mask_avx512_check(b + 4, a, c, MAX_SIZE), false);
	ASSERT_EQ(mask_avx512_check(b, a + 4, c, MAX_SIZE), false);
	ASSERT_EQ(mask_avx512_check(b, a, c + 4, MAX_SIZE), false);
	ASSERT_EQ(mask_avx512_check(b, a, c, MAX_SIZE - 4), false);
}

TEST(avx512_6, blend_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	ASSERT_EQ(blend_avx512_check(b, a, c, MAX_SIZE), true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		if (i & 1)
			ASSERT_EQ(c[i], b[i] * 2);
		else
			ASSERT_EQ(c[i], b[i] / 2);
	}

	ASSERT_EQ(blend_avx512_check(NULL, a, c, MAX_SIZE), false);
	ASSERT_EQ(blend_avx512_check(b, NULL, c, MAX_SIZE), false);
	ASSERT_EQ(blend_avx512_check(b, a, NULL, MAX_SIZE), false);
	ASSERT_EQ(blend_avx512_check(b + 4, a, c, MAX_SIZE), false);
	ASSERT_EQ(blend_avx512_check(b, a + 4, c, MAX_SIZE), false);
	ASSERT_EQ(blend_avx512_check(b, a, c + 4, MAX_SIZE), false);
	ASSERT_EQ(blend_avx512_check(b, a, c, MAX_SIZE - 8), false);
}
