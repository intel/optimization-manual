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

#include "cond_scalar.h"
#include "cond_vmaskmov.h"

const int MAX_SIZE = 1024; /* Size should be divisible by 8 */

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float a[MAX_SIZE];
__declspec(align(32)) static float b[MAX_SIZE];
__declspec(align(32)) static float c[MAX_SIZE];
__declspec(align(32)) static float d[MAX_SIZE];
__declspec(align(32)) static float e[MAX_SIZE];
#else
static float a[MAX_SIZE] __attribute__((aligned(32)));
static float b[MAX_SIZE] __attribute__((aligned(32)));
static float c[MAX_SIZE] __attribute__((aligned(32)));
static float d[MAX_SIZE] __attribute__((aligned(32)));
static float e[MAX_SIZE] __attribute__((aligned(32)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = (float)(i & 1);
		b[i] = 0.0;
		e[i] = (float)i;
		c[i] = (float)i * 2;
		d[i] = (float)i * 3;
	}
}

TEST(avx_14, cond_scalar)
{
	init_sources();
	ASSERT_EQ(cond_scalar_check(a, b, d, c, e, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		float expected = i & 1 ? e[i] * c[i] : e[i] * d[i];
		ASSERT_FLOAT_EQ(expected, b[i]);
	}
	ASSERT_EQ(cond_scalar_check(NULL, b, d, c, e, MAX_SIZE), false);
	ASSERT_EQ(cond_scalar_check(a, NULL, d, c, e, MAX_SIZE), false);
	ASSERT_EQ(cond_scalar_check(a, b, NULL, c, e, MAX_SIZE), false);
	ASSERT_EQ(cond_scalar_check(a, b, d, NULL, e, MAX_SIZE), false);
	ASSERT_EQ(cond_scalar_check(a, b, d, c, NULL, MAX_SIZE), false);
}

TEST(avx_14, cond_vmaskmov)
{
	init_sources();
	ASSERT_EQ(cond_vmaskmov_check(a, b, d, c, e, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		float expected = i & 1 ? e[i] * c[i] : e[i] * d[i];
		ASSERT_FLOAT_EQ(expected, b[i]);
	}
	ASSERT_EQ(cond_vmaskmov_check(NULL, b, d, c, e, MAX_SIZE), false);
	ASSERT_EQ(cond_vmaskmov_check(a, NULL, d, c, e, MAX_SIZE), false);
	ASSERT_EQ(cond_vmaskmov_check(a, b, NULL, c, e, MAX_SIZE), false);
	ASSERT_EQ(cond_vmaskmov_check(a, b, d, NULL, e, MAX_SIZE), false);
	ASSERT_EQ(cond_vmaskmov_check(a, b, d, c, NULL, MAX_SIZE), false);
	ASSERT_EQ(cond_vmaskmov_check(a, b, d, c, e, MAX_SIZE - 1), false);
}
