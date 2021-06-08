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

#include "embedded_broadcast.h"
#include "memory_broadcast.h"
#include "register_broadcast.h"

const size_t MAX_ITERATIONS = 32;
static uint32_t broadcast_values[MAX_ITERATIONS];

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t indices[16];
__declspec(align(64)) static uint32_t input[16];
__declspec(align(64)) static uint32_t output[16];
#else
static uint32_t indices[16] __attribute__((aligned(64)));
static uint32_t input[16] __attribute__((aligned(64)));
static uint32_t output[16] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (uint32_t i = 0; i < 16; i++)
		indices[i] = 15 - i;
	for (uint32_t i = 0; i < MAX_ITERATIONS; i++)
		broadcast_values[i] = i + 1;
	for (uint32_t i = 0; i < 16; i++) {
		input[i] = i;
		output[i] = 0;
	}
}

TEST(avx512_14, register_broadcast)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(register_broadcast_check(input, output, MAX_ITERATIONS,
					   broadcast_values, indices),
		  true);

	for (size_t j = 0; j < 16; j++) {
		uint32_t expected =
		    input[(15 - j)] + broadcast_values[MAX_ITERATIONS - 1];
		ASSERT_EQ(expected, output[j]);
	}

	ASSERT_EQ(register_broadcast_check(NULL, output, MAX_ITERATIONS,
					   broadcast_values, indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, NULL, MAX_ITERATIONS,
					   broadcast_values, indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, output, 0, broadcast_values,
					   indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, output, MAX_ITERATIONS, NULL,
					   indices),
		  false);
	ASSERT_EQ(register_broadcast_check(input, output, MAX_ITERATIONS,
					   broadcast_values, NULL),
		  false);
}

TEST(avx512_14, memory_broadcast)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(memory_broadcast_check(input, output, MAX_ITERATIONS,
					 broadcast_values, indices),
		  true);

	for (size_t j = 0; j < 16; j++) {
		uint32_t expected =
		    input[(15 - j)] + broadcast_values[MAX_ITERATIONS - 1];
		ASSERT_EQ(expected, output[j]);
	}

	ASSERT_EQ(memory_broadcast_check(NULL, output, MAX_ITERATIONS,
					 broadcast_values, indices),
		  false);
	ASSERT_EQ(memory_broadcast_check(input, NULL, MAX_ITERATIONS,
					 broadcast_values, indices),
		  false);
	ASSERT_EQ(
	    memory_broadcast_check(input, output, 0, broadcast_values, indices),
	    false);
	ASSERT_EQ(memory_broadcast_check(input, output, MAX_ITERATIONS, NULL,
					 indices),
		  false);
	ASSERT_EQ(memory_broadcast_check(input, output, MAX_ITERATIONS,
					 broadcast_values, NULL),
		  false);
}

TEST(avx512_14, embedded_broadcast)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(embedded_broadcast_check(input, output, MAX_ITERATIONS,
					   broadcast_values, indices),
		  true);
	for (size_t j = 0; j < 16; j++) {
		uint32_t expected =
		    input[(15 - j)] + broadcast_values[MAX_ITERATIONS - 1];
		ASSERT_EQ(expected, output[j]);
	}

	ASSERT_EQ(embedded_broadcast_check(NULL, output, MAX_ITERATIONS,
					   broadcast_values, indices),
		  false);
	ASSERT_EQ(embedded_broadcast_check(input, NULL, MAX_ITERATIONS,
					   broadcast_values, indices),
		  false);
	ASSERT_EQ(embedded_broadcast_check(input, output, 0, broadcast_values,
					   indices),
		  false);
	ASSERT_EQ(embedded_broadcast_check(input, output, MAX_ITERATIONS, NULL,
					   indices),
		  false);
	ASSERT_EQ(embedded_broadcast_check(input, output, MAX_ITERATIONS,
					   broadcast_values, NULL),
		  false);
}
