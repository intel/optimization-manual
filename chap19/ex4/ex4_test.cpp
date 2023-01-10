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

#include <stdlib.h>

#ifdef COMPILER_SUPPORTS_FP16

#include "compress_ph_test.h"
#include "optimisation_common.h"

#define MAX_SIZE 32

TEST(fp16_4, compress_ph)
{
	if (!supports_avx512_icl())
		GTEST_SKIP_("AVX512 VBMI2 not supported");

	if (!supports_avx512_fp16())
		GTEST_SKIP_("FP16 not supported");

#ifdef _MSC_VER
	__declspec(align(64)) float floats[MAX_SIZE];
	__declspec(align(64)) uint16_t halves[MAX_SIZE];
	__declspec(align(64)) uint16_t compressed_halves[MAX_SIZE];
#else
	float floats[MAX_SIZE] __attribute__((aligned(64)));
	uint16_t halves[MAX_SIZE] __attribute__((aligned(64)));
	uint16_t compressed_halves[MAX_SIZE] __attribute__((aligned(64)));
#endif

	uint32_t mask = rand();
	for (size_t i = 0; i < MAX_SIZE; i++)
		floats[i] = ((float)rand() / (float)RAND_MAX);

	test_compress_ph(mask, floats, halves, compressed_halves);

	size_t counter = 0;
	for (size_t i = 0; i < MAX_SIZE; i++) {
		if (((1 << i) & mask) == 0)
			continue;
		ASSERT_EQ(halves[i], compressed_halves[counter]);
		counter++;
	}

	for (; counter < MAX_SIZE; counter++)
		ASSERT_EQ(compressed_halves[counter], 0);
}
#else
TEST(fp16_4, compress_ph) { GTEST_SKIP_("Compiler does not support FP16"); }
#endif
