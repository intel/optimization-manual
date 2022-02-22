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

#include "qword_avx2.h"
#include "qword_avx512.h"

const size_t MAX_SIZE = 1024;

static int64_t output_scalar[MAX_SIZE];

#ifdef _MSC_VER
__declspec(align(64)) static int64_t input_a[MAX_SIZE];
__declspec(align(64)) static int64_t input_b[MAX_SIZE];
__declspec(align(64)) static int64_t output[MAX_SIZE];
#else
static int64_t input_a[MAX_SIZE] __attribute__((aligned(64)));
static int64_t input_b[MAX_SIZE] __attribute__((aligned(64)));
static int64_t output[MAX_SIZE] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		input_a[i] = rand() - (RAND_MAX / 2);
		input_b[i] = rand() - (RAND_MAX / 2);
	}

	for (size_t i = 0; i < MAX_SIZE; i++) {
		int64_t sum = input_a[i] + input_b[i];
		int64_t mul = input_a[i] * input_b[i];
		output_scalar[i] = mul > sum ? mul : sum;
	}
}

TEST(avx512_18, qword_avx2_instrinics)
{
	init_sources();

	memset(output, 0, MAX_SIZE * sizeof(int64_t));
	ASSERT_EQ(
	    qword_avx2_intrinsics_check(input_a, input_b, output, MAX_SIZE),
	    true);
	for (size_t i = 0; i < MAX_SIZE; i++)
		ASSERT_EQ(output[i], output_scalar[i]);
}

TEST(avx512_18, qword_avx512_instrinics)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	memset(output, 0, MAX_SIZE * sizeof(int64_t));
	ASSERT_EQ(
	    qword_avx512_intrinsics_check(input_a, input_b, output, MAX_SIZE),
	    true);
	for (size_t i = 0; i < MAX_SIZE; i++)
		ASSERT_EQ(output[i], output_scalar[i]);
}

TEST(avx512_18, qword_avx2_ass)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	memset(output, 0, MAX_SIZE * sizeof(int64_t));
	ASSERT_EQ(qword_avx2_ass_check(input_a, input_b, output, MAX_SIZE),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++)
		ASSERT_EQ(output[i], output_scalar[i]);
}

TEST(avx512_18, qword_avx512_ass)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	memset(output, 0, MAX_SIZE * sizeof(int64_t));
	ASSERT_EQ(qword_avx512_ass_check(input_a, input_b, output, MAX_SIZE),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++)
		ASSERT_EQ(output[i], output_scalar[i]);
}
