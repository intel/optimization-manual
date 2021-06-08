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

#include "hardware_scatter.h"
#include "scalar_scatter.h"
#include "software_scatter.h"

const size_t MAX_ITERATIONS = 32;
const size_t MAX_INPUTS = MAX_ITERATIONS * 8;
const size_t MAX_OUTPUTS = MAX_ITERATIONS * 8 * 4;

static float output_scalar[MAX_OUTPUTS];

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t indices[MAX_INPUTS];
__declspec(align(64)) static uint64_t input[MAX_INPUTS];
__declspec(align(64)) static float output[MAX_OUTPUTS];
#else
static uint32_t indices[MAX_INPUTS] __attribute__((aligned(64)));
static uint64_t input[MAX_INPUTS] __attribute__((aligned(64)));
static float output[MAX_OUTPUTS] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (uint32_t i = 0; i < MAX_INPUTS; i++) {
		indices[i] = i * 4;
		input[i] = rand();
	}
	memset(output_scalar, 0, MAX_OUTPUTS * sizeof(float));

	for (size_t i = 0; i < MAX_INPUTS; i++)
		output_scalar[indices[i]] = (float)input[i];
}

TEST(avx512_17, scalar_scatter)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	memset(output, 0, MAX_OUTPUTS * sizeof(float));
	ASSERT_EQ(scalar_scatter_check(input, indices, MAX_INPUTS * 4, output),
		  true);
	for (size_t i = 0; i < MAX_OUTPUTS; i++)
		ASSERT_EQ(output[i], output_scalar[i]);

	ASSERT_EQ(scalar_scatter_check(input, indices, 7, output), false);
	ASSERT_EQ(scalar_scatter_check(input, indices, 0, output), false);
	ASSERT_EQ(scalar_scatter_check(NULL, indices, MAX_INPUTS * 4, output),
		  false);
	ASSERT_EQ(scalar_scatter_check(input, NULL, MAX_INPUTS * 4, output),
		  false);
	ASSERT_EQ(scalar_scatter_check(input, indices, MAX_INPUTS * 4, NULL),
		  false);
}

TEST(avx512_17, software_scatter)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	memset(output, 0, MAX_OUTPUTS * sizeof(float));
	ASSERT_EQ(
	    software_scatter_check(input, indices, MAX_INPUTS * 4, output),
	    true);
	for (size_t i = 0; i < MAX_OUTPUTS; i++)
		ASSERT_EQ(output[i], output_scalar[i]);

	ASSERT_EQ(software_scatter_check(input, indices, 7, output), false);
	ASSERT_EQ(software_scatter_check(input, indices, 0, output), false);
	ASSERT_EQ(software_scatter_check(NULL, indices, MAX_INPUTS * 4, output),
		  false);
	ASSERT_EQ(software_scatter_check(input, NULL, MAX_INPUTS * 4, output),
		  false);
	ASSERT_EQ(software_scatter_check(input, indices, MAX_INPUTS * 4, NULL),
		  false);
}

TEST(avx512_17, hardware_scatter)
{

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	memset(output, 0, MAX_OUTPUTS * sizeof(float));
	ASSERT_EQ(
	    hardware_scatter_check(input, indices, MAX_INPUTS * 4, output),
	    true);
	for (size_t i = 0; i < MAX_OUTPUTS; i++)
		ASSERT_EQ(output[i], output_scalar[i]);

	ASSERT_EQ(hardware_scatter_check(input, indices, 7, output), false);
	ASSERT_EQ(hardware_scatter_check(input, indices, 0, output), false);
	ASSERT_EQ(hardware_scatter_check(NULL, indices, MAX_INPUTS * 4, output),
		  false);
	ASSERT_EQ(hardware_scatter_check(input, NULL, MAX_INPUTS * 4, output),
		  false);
	ASSERT_EQ(hardware_scatter_check(input, indices, MAX_INPUTS * 4, NULL),
		  false);
}
