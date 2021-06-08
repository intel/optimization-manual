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

#include "optimisation_common.h"
#include "sigmoid_approx_avx512.h"

#include <math.h>

#ifdef _MSC_VER
__declspec(align(64)) float input[16];
__declspec(align(64)) float output[16];
#else
float input[16] __attribute__((aligned(64)));
float output[16] __attribute__((aligned(64)));
#endif

float scalar_output[16];

void init_data()
{
	srand(0);
	for (size_t i = 0; i < 16; i++) {
		input[i] = (float)((((double)std::rand()) - (RAND_MAX / 2)) /
				   RAND_MAX);
		output[i] = 0.0f;
		scalar_output[i] = 0.0f;
	}
}

void scalar_sigmoid(float *input, float *output)
{
	for (size_t i = 0; i < 16; i++)
		output[i] = (float)1.0 / (expf(-input[i]) + 1);
}

TEST(vnni, sigmoid_approx)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();

	sigmoid_poly_2_avx512(input, output);

	scalar_sigmoid(input, scalar_output);
	for (size_t i = 0; i < 16; i++) {
		ASSERT_NEAR(scalar_output[i], output[i], 0.00001);
	}
}
