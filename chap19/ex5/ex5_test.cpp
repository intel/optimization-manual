/*
 * Copyright (C) 2022 by Intel Corporation
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

#include <stdint.h>
#include <stdlib.h>

#ifdef COMPILER_SUPPORTS_FP16

#include "fast_special_min_test.h"
#include "optimisation_common.h"

#define MAX_SIZE 8

TEST(fp16_5, fast_special_min)
{
	if (!supports_avx512_fp16())
		GTEST_SKIP_("FP16 not supported");

#ifdef _MSC_VER
	__declspec(align(64)) float floats[MAX_SIZE * 2];
	__declspec(align(64)) uint16_t halves[MAX_SIZE * 2];
	__declspec(align(64)) uint16_t mins[MAX_SIZE];
#else
	float floats[MAX_SIZE * 2] __attribute__((aligned(64)));
	uint16_t halves[MAX_SIZE * 2] __attribute__((aligned(64)));
	uint16_t mins[MAX_SIZE] __attribute__((aligned(64)));
#endif

	for (size_t i = 0; i < MAX_SIZE * 2; i++)
		floats[i] = ((float)rand() / (float)RAND_MAX);

	test_fast_special_min(floats, halves, mins);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		if (floats[i] < floats[i + MAX_SIZE])
			ASSERT_EQ(mins[i], halves[i]);
		else
			ASSERT_EQ(mins[i], halves[MAX_SIZE + i]);
	}

	/*
	 * Lets try a mix of positive and negative numbers ensuring
	 * that the values being compared have different signs.
	 */

	size_t i = 0;
	for (; i < MAX_SIZE; i++)
		floats[i] = ((float)rand() / (float)RAND_MAX);

	for (; i < MAX_SIZE * 2; i++) {
		floats[i] = ((float)rand() / (float)RAND_MAX);
		if (rand() & 1)
			floats[i] = -floats[i];
	}

	test_fast_special_min(floats, halves, mins);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		if (floats[i] < floats[i + MAX_SIZE])
			ASSERT_EQ(mins[i], halves[i]);
		else
			ASSERT_EQ(mins[i], halves[MAX_SIZE + i]);
	}
}
#else
TEST(fp16_5, fast_special_min)
{
	GTEST_SKIP_("Compiler does not support FP16");
}
#endif
