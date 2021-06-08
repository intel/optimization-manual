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

#include "optimisation_common.h"
#include "saxpy_512.h"

const int MAX_SIZE = 4096;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static float src[MAX_SIZE];
__declspec(align(64)) static float dest[MAX_SIZE];
__declspec(align(64)) static float src2[MAX_SIZE];
#else
static float src[MAX_SIZE] __attribute__((aligned(64)));
static float dest[MAX_SIZE] __attribute__((aligned(64)));
static float src2[MAX_SIZE] __attribute__((aligned(64)));
#endif

void init_sources()
{
	for (int i = 0; i < MAX_SIZE; i++) {
		src[i] = 2.0f * i;
		src2[i] = 3.0f * i;
	}
}

TEST(avx512_29, saxpy_512)
{
	float val;

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(saxpy_512_check(src, src2, MAX_SIZE, dest, 10.0), true);
	for (int i = 0; i < MAX_SIZE; i++) {
		val = 10 * src[i] + src2[i];
		ASSERT_FLOAT_EQ(dest[i], val);
	}

	ASSERT_EQ(saxpy_512_check(NULL, src2, MAX_SIZE, dest, 10.0), false);
	ASSERT_EQ(saxpy_512_check(src, NULL, MAX_SIZE, dest, 10.0), false);
	ASSERT_EQ(saxpy_512_check(src, src2, MAX_SIZE, NULL, 10.0), false);
	ASSERT_EQ(saxpy_512_check(src, src2, (MAX_SIZE - 2), dest, 10.0),
		  false);
}
