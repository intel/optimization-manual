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

#include <cmath>
#include <cstdlib>

#include "optimisation_common.h"
#include "quantization_avx512.hpp"
#include "quantization_scalar.hpp"

#define MAX_ACTIVATIONS 4096

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) float raw_data[MAX_ACTIVATIONS];
__declspec(align(64)) u8 scalar_res[MAX_ACTIVATIONS];
__declspec(align(64)) u8 avx512_res[MAX_ACTIVATIONS];
#else
float raw_data[MAX_ACTIVATIONS] __attribute__((aligned(64)));
u8 scalar_res[MAX_ACTIVATIONS] __attribute__((aligned(64)));
u8 avx512_res[MAX_ACTIVATIONS] __attribute__((aligned(64)));
#endif

float init_data()
{
	float max = 1.0;

	for (size_t i = 0; i < MAX_ACTIVATIONS; i++) {
		raw_data[i] = (float)(((double)std::rand()) / RAND_MAX);
		if (raw_data[i] > max)
			max = std::fabs(raw_data[i]);
	}

	return 255.0f / max;
}

TEST(vnni, quantization)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	float factor = init_data();

	quantize_activations_scalar(raw_data, scalar_res, MAX_ACTIVATIONS,
				    factor, 8);
	quantize_activations_avx512(raw_data, avx512_res, MAX_ACTIVATIONS,
				    factor, 8);

	for (size_t i = 0; i < MAX_ACTIVATIONS; i++) {
		ASSERT_FLOAT_EQ(scalar_res[i], avx512_res[i]);
	}
}
