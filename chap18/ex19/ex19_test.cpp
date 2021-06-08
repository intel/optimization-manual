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

#include "avx512_histogram.h"
#include "optimisation_common.h"
#include "scalar_histogram.h"

/*
 * We choose a small number of bins to make conflict more likely.
 */

const size_t MAX_BINS = 32;
const size_t MAX_INPUTS = 2048;

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t ref_histogram[MAX_BINS];
__declspec(align(64)) static uint32_t histogram[MAX_BINS];
__declspec(align(64)) static int32_t inputs[MAX_INPUTS];
#else
static uint32_t ref_histogram[MAX_BINS] __attribute__((aligned(64)));
static uint32_t histogram[MAX_BINS] __attribute__((aligned(64)));
static int32_t inputs[MAX_INPUTS] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	memset(ref_histogram, 0, sizeof(ref_histogram));
	for (size_t i = 0; i < MAX_INPUTS; i++) {
		inputs[i] = rand();
		ref_histogram[inputs[i] & (MAX_BINS - 1)]++;
	}
}

TEST(avx512_19, scalar_histogram)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	memset(histogram, 0, sizeof(histogram));
	ASSERT_EQ(
	    scalar_histogram_check(inputs, histogram, MAX_INPUTS, MAX_BINS),
	    true);
	for (size_t i = 0; i < MAX_BINS; i++)
		ASSERT_EQ(histogram[i], ref_histogram[i]);

	ASSERT_EQ(scalar_histogram_check(NULL, histogram, MAX_INPUTS, MAX_BINS),
		  false);
	ASSERT_EQ(scalar_histogram_check(inputs, NULL, MAX_INPUTS, MAX_BINS),
		  false);
	ASSERT_EQ(scalar_histogram_check(inputs, histogram, 1, MAX_BINS),
		  false);
	ASSERT_EQ(scalar_histogram_check(inputs, histogram, 0, MAX_BINS),
		  false);
	ASSERT_EQ(scalar_histogram_check(inputs, histogram, MAX_INPUTS, 33),
		  false);
}

TEST(avx512_19, avx512_histogram)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	memset(histogram, 0, sizeof(histogram));
	ASSERT_EQ(
	    avx512_histogram_check(inputs, histogram, MAX_INPUTS, MAX_BINS),
	    true);
	for (size_t i = 0; i < MAX_BINS; i++)
		ASSERT_EQ(histogram[i], ref_histogram[i]);

	ASSERT_EQ(avx512_histogram_check(NULL, histogram, MAX_INPUTS, MAX_BINS),
		  false);
	ASSERT_EQ(avx512_histogram_check(inputs, NULL, MAX_INPUTS, MAX_BINS),
		  false);
	ASSERT_EQ(avx512_histogram_check(inputs, histogram, 0, MAX_BINS),
		  false);
	ASSERT_EQ(avx512_histogram_check(inputs, histogram, 24, MAX_BINS),
		  false);
	ASSERT_EQ(avx512_histogram_check(inputs, histogram, MAX_INPUTS, 33),
		  false);
}
