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

#include <random>

#include "optimisation_common.h"
#include "gtest/gtest.h"

#ifdef COMPILER_SUPPORTS_AVX512_BF16

#include "bf16_conv.h"

#define MAX_ELEMENTS 512

alignas(64) static float spad[MAX_ELEMENTS];
alignas(64) static bfloat_16 next_inputs[MAX_ELEMENTS];
inline unsigned int inputs_spatial_dim(void) { return 1; }

void init_sources()
{
	std::random_device rd;
	std::default_random_engine eng(rd());
	std::uniform_real_distribution<> dist(-1.0, 1.0);

	for (size_t i = 0; i < MAX_ELEMENTS; i++)
		spad[i] = dist(eng);
}

TEST(amx_19, amx_conv_block_int8)
{
	if (!supports_avx512_skx() || !supports_avx512_bf16())
		GTEST_SKIP_("AVX512_BF16 not supported, skipping test");

	init_sources();

	ASSERT_EQ(bf16_conv_check(spad, next_inputs, inputs_spatial_dim), true);

	size_t bfindex = 0;
	for (size_t i = 0; i < MAX_ELEMENTS / (16 * 2); i++) {
		for (size_t off = 0; off < 512; off += 256) {
			for (size_t j = 0; j < 16; j++) {
				uint16_t a[2];
				a[0] = 0;
				a[1] = next_inputs[bfindex++];
				float b;
				memcpy(&b, a, sizeof(b));
				ASSERT_NEAR(spad[off + i * 16 + j], b, 0.01);
			}
		}
	}
}
#else
TEST(amx_19, amx_conv_block_int8)
{
	GTEST_SKIP_("Compiler does not support AVX512_BF16, skipping test");
}
#endif
