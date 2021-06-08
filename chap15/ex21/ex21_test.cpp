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

#include "mul_cpx_mem.h"
#include "mul_cpx_reg.h"

const int MAX_SIZE = 4096; /* Must divisible by 8 */

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static complex_num x[MAX_SIZE];
__declspec(align(32)) static complex_num y[MAX_SIZE];
__declspec(align(32)) static complex_num z[MAX_SIZE];
#else
static complex_num x[MAX_SIZE] __attribute__((aligned(32)));
static complex_num y[MAX_SIZE] __attribute__((aligned(32)));
static complex_num z[MAX_SIZE] __attribute__((aligned(32)));
#endif

void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		x[i].real = (float)i;
		x[i].imaginary = (float)i + 1;
		y[i].real = x[i].real * 2;
		y[i].imaginary = x[i].imaginary * 2;
		z[i].real = 0.0;
		z[i].imaginary = 0.0;
	}
}

inline complex_num operator*(const complex_num &a, const complex_num &b)
{
	complex_num res;

	res.real = (a.real * b.real) - (a.imaginary * b.imaginary);
	res.imaginary = (a.real * b.imaginary) + (b.real * a.imaginary);

	return res;
}

static void prv_check_result(void)
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		complex_num expected = x[i] * y[i];

		ASSERT_FLOAT_EQ(z[i].real, expected.real);
		ASSERT_FLOAT_EQ(z[i].imaginary, expected.imaginary);
	}
}

TEST(avx_21, mul_cpx_reg)
{
	init_sources();
	ASSERT_EQ(mul_cpx_reg_check(x, y, z, MAX_SIZE), true);
	prv_check_result();
	ASSERT_EQ(mul_cpx_reg_check(NULL, y, z, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_reg_check(x, NULL, z, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_reg_check(x, y, NULL, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_reg_check(x + 1, y, z, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_reg_check(x, y + 1, z, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_reg_check(x, y, z + 1, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_reg_check(x, y, z + 1, 0), false);
	ASSERT_EQ(mul_cpx_reg_check(x, y, z + 1, MAX_SIZE - 1), false);
}

TEST(avx_21, mul_cpx_mem)
{
	init_sources();
	ASSERT_EQ(mul_cpx_mem_check(x, y, z, MAX_SIZE), true);
	prv_check_result();
	ASSERT_EQ(mul_cpx_mem_check(NULL, y, z, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_mem_check(x, NULL, z, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_mem_check(x, y, NULL, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_mem_check(x + 1, y, z, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_mem_check(x, y, z + 1, MAX_SIZE), false);
	ASSERT_EQ(mul_cpx_mem_check(x, y, z + 1, 0), false);
	ASSERT_EQ(mul_cpx_mem_check(x, y, z + 1, MAX_SIZE - 1), false);
}
