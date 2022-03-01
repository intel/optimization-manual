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

#include "fp_fma.h"
#include "fp_mul_add.h"

const int MAX_SIZE = 8;
const int MAX_ITERS = 5;

static float a[8];
static float c1[8];
static float c2[8];

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = i * 1.0f;
		c1[i] = i * 2.0f;
		c2[i] = i * 4.0f;
	}
}

TEST(avx_35, fp_mul_add)
{
	init_sources();
	ASSERT_EQ(fp_mul_add_check(a, c1, c2, MAX_ITERS), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		float a_scalar = i * 1.0f;
		float c1_scalar = i * 2.0f;
		float c2_scalar = i * 4.0f;
		for (size_t j = 0; j < MAX_ITERS; j++) {
			a_scalar = (a_scalar * c2_scalar) + c1_scalar;
		}
		ASSERT_FLOAT_EQ(a[i], a_scalar);
	}
	ASSERT_EQ(fp_mul_add_check(NULL, c1, c2, MAX_ITERS), false);
	ASSERT_EQ(fp_mul_add_check(a, NULL, c2, MAX_ITERS), false);
	ASSERT_EQ(fp_mul_add_check(a, c1, NULL, MAX_ITERS), false);
	ASSERT_EQ(fp_mul_add_check(a, c1, c2, 0), false);
}

TEST(avx_35, fp_fma)
{
	init_sources();
	ASSERT_EQ(fp_fma_check(a, c1, c2, MAX_ITERS), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		float a_scalar = i * 1.0f;
		float c1_scalar = i * 2.0f;
		float c2_scalar = i * 4.0f;
		for (size_t j = 0; j < MAX_ITERS; j++) {
			a_scalar = (a_scalar * c2_scalar) + c1_scalar;
		}
		ASSERT_FLOAT_EQ(a[i], a_scalar);
	}
	ASSERT_EQ(fp_fma_check(NULL, c1, c2, MAX_ITERS), false);
	ASSERT_EQ(fp_fma_check(a, NULL, c2, MAX_ITERS), false);
	ASSERT_EQ(fp_fma_check(a, c1, NULL, MAX_ITERS), false);
	ASSERT_EQ(fp_fma_check(a, c1, c2, 0), false);
}
