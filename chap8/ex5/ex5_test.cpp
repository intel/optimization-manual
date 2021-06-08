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

#include <limits.h>

#include "optimisation_common.h"
#include "post_conv.hpp"

#define MAX_ACTIVATIONS 4096

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) float bias[16];
__declspec(align(64)) float dqfs[16];
__declspec(align(16)) int8_t dest[16];
__declspec(align(64)) uint32_t output[16];
#else
float bias[16] __attribute__((aligned(64)));
float dqfs[16] __attribute__((aligned(64)));
int8_t dest[16] __attribute__((aligned(16)));
uint32_t output[16] __attribute__((aligned(64)));
#endif
int8_t dest_scalar[16];

static void init_data()
{
	uint32_t max = 1;

	for (size_t i = 0; i < 16; i++) {
		output[i] = std::rand() % INT_MAX;
		if (output[i] > max)
			max = output[i];
		bias[i] = (float)(((double)std::rand()) / RAND_MAX);
		dest[i] = 0;
		dest_scalar[i] = 0;
	}
	float b = 255.0f / max;

	for (size_t i = 0; i < 16; i++) {
		dqfs[i] = b;
	}
}

TEST(vnni, post_conv)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	srand(0);
	init_data();

	basic_post_conv(output, dest, 0, 0, bias, dqfs);
	post_conv_scalar(output, dest_scalar, 0, 0, bias, dqfs, dest_scalar);
	for (size_t i = 0; i < 16; i++) {
		ASSERT_EQ(dest[i], dest_scalar[i]);
	}
}
