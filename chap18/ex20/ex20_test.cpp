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

#include "avx512_vector_dp.h"
#include "init_sparse.h"
#include "optimisation_common.h"
#include "scalar_vector_dp.h"

const size_t MAX_SIZE = 2048;
const size_t MAX_ELS = MAX_SIZE / 4;
static double ref_sum;

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t a_index[MAX_SIZE];
__declspec(align(64)) static double a_values[MAX_ELS];
__declspec(align(64)) static uint32_t b_index[MAX_SIZE];
__declspec(align(64)) static double b_values[MAX_ELS];
#else
static uint32_t a_index[MAX_SIZE] __attribute__((aligned(64)));
static double a_values[MAX_ELS] __attribute__((aligned(64)));
static uint32_t b_index[MAX_SIZE] __attribute__((aligned(64)));
static double b_values[MAX_ELS] __attribute__((aligned(64)));
#endif

static void compute_ref_sum()
{
	size_t a_offset = 0;
	size_t b_offset = 0;

	ref_sum = 0.0;

	while ((a_offset < MAX_ELS) && (b_offset < MAX_ELS)) {
		if (a_index[a_offset] == b_index[b_offset]) { // match
			ref_sum += a_values[a_offset] * b_values[b_offset];
			a_offset++;
			b_offset++;
		} else if (a_index[a_offset] < b_index[b_offset]) {
			a_offset++;
		} else {
			b_offset++;
		}
	}
}

static void init_sources()
{
	init_sparse(a_index, a_values, b_index, b_values, MAX_ELS);
	compute_ref_sum();
}

TEST(avx512_20, scalar_vector_dp)
{
	double sum;

	srand(0);

	init_sources();
	sum = 0.0;

	ASSERT_EQ(scalar_vector_dp_check(a_index, a_values, b_index, b_values,
					 MAX_ELS, &sum),
		  true);
	ASSERT_NEAR(sum, ref_sum, 0.01);
	ASSERT_EQ(scalar_vector_dp_check(NULL, a_values, b_index, b_values,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(scalar_vector_dp_check(a_index, NULL, b_index, b_values,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(scalar_vector_dp_check(a_index, a_values, NULL, b_values,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(scalar_vector_dp_check(a_index, a_values, b_index, NULL,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(scalar_vector_dp_check(a_index, a_values, b_index, b_values,
					 MAX_ELS, NULL),
		  false);
}

TEST(avx512_20, avx512_vector_dp)
{
	double sum;

	srand(0);

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	sum = 0.0;

	ASSERT_EQ(avx512_vector_dp_check(a_index, a_values, b_index, b_values,
					 MAX_ELS, &sum),
		  true);
	ASSERT_NEAR(sum, ref_sum, 0.01);
	ASSERT_EQ(avx512_vector_dp_check(NULL, a_values, b_index, b_values,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(avx512_vector_dp_check(a_index, NULL, b_index, b_values,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(avx512_vector_dp_check(a_index, a_values, NULL, b_values,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(avx512_vector_dp_check(a_index, a_values, b_index, NULL,
					 MAX_ELS, &sum),
		  false);
	ASSERT_EQ(avx512_vector_dp_check(a_index, a_values, b_index, b_values,
					 MAX_ELS, NULL),
		  false);
	ASSERT_EQ(avx512_vector_dp_check(a_index, a_values, b_index, b_values,
					 7, &sum),
		  false);
}
