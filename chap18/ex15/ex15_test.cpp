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

#include "memory_broadcast.h"
#include "register_broadcast.h"

const size_t MAX_ITERATIONS = 32;
static uint32_t broadcast_values_32[MAX_ITERATIONS];
static uint16_t broadcast_values_16[MAX_ITERATIONS];

#ifdef _MSC_VER
__declspec(align(64)) static uint16_t indices[MAX_ITERATIONS];
__declspec(align(64)) static uint16_t input[MAX_ITERATIONS];
__declspec(align(64)) static uint16_t output[MAX_ITERATIONS];
#else
static uint16_t indices[MAX_ITERATIONS] __attribute__((aligned(64)));
static uint16_t input[MAX_ITERATIONS] __attribute__((aligned(64)));
static uint16_t output[MAX_ITERATIONS] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_ITERATIONS; i++)
		indices[i] = (int16_t)((MAX_ITERATIONS - 1) - i);
	for (size_t i = 0; i < MAX_ITERATIONS; i++) {
		broadcast_values_32[i] = (uint32_t)i + 1;
		broadcast_values_16[i] = (int16_t)(i + 1);
	}
	for (size_t i = 0; i < MAX_ITERATIONS; i++) {
		input[i] = (int16_t)i;
		output[i] = (int16_t)0;
	}
}

TEST(avx512_15, register_broadcast)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(register_broadcast_check(input, output, MAX_ITERATIONS,
					   broadcast_values_32, indices),
		  true);

	for (size_t j = 0; j < MAX_ITERATIONS; j++) {
		uint16_t expected =
		    input[((MAX_ITERATIONS - 1) - j)] +
		    ((int16_t)broadcast_values_32[MAX_ITERATIONS - 1]);
		ASSERT_EQ(expected, output[j]);
	}

	ASSERT_EQ(register_broadcast_check(NULL, output, MAX_ITERATIONS,
					   broadcast_values_32, indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, NULL, MAX_ITERATIONS,
					   broadcast_values_32, indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, output, 0,
					   broadcast_values_32, indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, output, MAX_ITERATIONS, NULL,
					   indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, output, MAX_ITERATIONS,
					   broadcast_values_32, NULL),
		  false);
}

TEST(avx512_15, memory_broadcast)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(memory_broadcast_check(input, output, MAX_ITERATIONS,
					 broadcast_values_16, indices),
		  true);

	for (size_t j = 0; j < MAX_ITERATIONS; j++) {
		uint16_t expected = input[((MAX_ITERATIONS - 1) - j)] +
				    broadcast_values_16[MAX_ITERATIONS - 1];
		ASSERT_EQ(expected, output[j]);
	}

	ASSERT_EQ(memory_broadcast_check(NULL, output, MAX_ITERATIONS,
					 broadcast_values_16, indices),
		  false);
	ASSERT_EQ(memory_broadcast_check(input, NULL, MAX_ITERATIONS,
					 broadcast_values_16, indices),
		  false);
	ASSERT_EQ(memory_broadcast_check(input, output, 0, broadcast_values_16,
					 indices),
		  false);
	ASSERT_EQ(memory_broadcast_check(input, output, MAX_ITERATIONS, NULL,
					 indices),
		  false);
	ASSERT_EQ(memory_broadcast_check(input, output, MAX_ITERATIONS,
					 broadcast_values_16, NULL),
		  false);
}
