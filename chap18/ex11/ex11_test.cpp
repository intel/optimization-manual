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

#include "expand_avx2.h"
#include "expand_avx512.h"
#include "expand_scalar.h"
#include "optimisation_common.h"

const size_t MAX_SIZE = 4096;

#ifdef _MSC_VER
__declspec(align(64)) static int32_t a[MAX_SIZE];
__declspec(align(64)) static int32_t b[MAX_SIZE];
#else
static int32_t a[MAX_SIZE] __attribute__((aligned(64)));
static int32_t b[MAX_SIZE] __attribute__((aligned(64)));
#endif

static int32_t expected[MAX_SIZE];

static void init_sources()
{
	int32_t counter = 0;
	for (size_t i = 0; i < MAX_SIZE; i += 2048) {
		for (size_t j = 0; j < 256; j++) {
			if (j & 1)
				a[i + (j * 8)] = counter++;
			if (j & 2)
				a[i + (j * 8) + 1] = counter++;
			if (j & 4)
				a[i + (j * 8) + 2] = counter++;
			if (j & 8)
				a[i + (j * 8) + 3] = counter++;
			if (j & 16)
				a[i + (j * 8) + 4] = counter++;
			if (j & 32)
				a[i + (j * 8) + 5] = counter++;
			if (j & 64)
				a[i + (j * 8) + 6] = counter++;
			if (j & 128)
				a[i + (j * 8) + 7] = counter++;
		}
	}

	counter = 0;
	for (size_t i = 0; i < MAX_SIZE; i++) {
		if (a[i] > 0)
			expected[i] = a[counter++];
	}
}

TEST(avx512_11, expand_scalar)
{
	init_sources();

	memset(b, 0, sizeof(b));
	ASSERT_EQ(expand_scalar_check(b, a, MAX_SIZE), true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(b[i], expected[i]);
	}

	ASSERT_EQ(expand_scalar_check(NULL, a, MAX_SIZE), false);
	ASSERT_EQ(expand_scalar_check(b, NULL, MAX_SIZE), false);
	ASSERT_EQ(expand_scalar_check(b, a, 0), false);
}

TEST(avx512_11, expand_avx2)
{
	init_sources();

	memset(b, 0, sizeof(b));
	ASSERT_EQ(expand_avx2_check(b, a, MAX_SIZE), true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(b[i], expected[i]);
	}

	ASSERT_EQ(expand_avx2_check(NULL, a, MAX_SIZE), false);
	ASSERT_EQ(expand_avx2_check(b, NULL, MAX_SIZE), false);
	ASSERT_EQ(expand_avx2_check(b, a + 4, MAX_SIZE), false);
	ASSERT_EQ(expand_avx2_check(b, a, MAX_SIZE - 4), false);
}

TEST(avx512_11, expand_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	memset(b, 0, sizeof(b));
	ASSERT_EQ(expand_avx512_check(b, a, MAX_SIZE), true);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(b[i], expected[i]);
	}

	ASSERT_EQ(expand_avx512_check(NULL, a, MAX_SIZE), false);
	ASSERT_EQ(expand_avx512_check(b, NULL, MAX_SIZE), false);
	ASSERT_EQ(expand_avx512_check(b, a + 8, MAX_SIZE), false);
	ASSERT_EQ(expand_avx512_check(b, a, MAX_SIZE - 8), false);
}
