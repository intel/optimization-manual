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

#include <stdlib.h>

#include "gtest/gtest.h"

#include "byte_decompression.h"
#include "optimisation_common.h"

#define M 8
#define N 64

alignas(64) static __mmask64 masks[M];
alignas(64) static uint8_t output[M][N];
static int len;

static uint8_t *init_sources()
{
	uint8_t *compressed;

	for (size_t m = 0; m < M; m++) {
		for (uint64_t i = 0; i < 8; i++) {
			uint8_t byte_mask = rand() % 256;
			masks[m] |= static_cast<uint64_t>(byte_mask) << (i * 8);
		}
		len += _mm_popcnt_u64(masks[m]);
	}

	compressed =
	    static_cast<uint8_t *>(_mm_malloc(((len / 64) + 2) * 64, 64));
	if (!compressed)
		return nullptr;

	for (int i = 0; i < len; i++)
		compressed[i] = static_cast<uint8_t>(i);

	return compressed;
}

TEST(amx_27, amx_byte_decompression)
{
	uint8_t *compressed;

	if (!supports_avx512_icl())
		GTEST_SKIP_("VBMI not supported, skipping test");

	compressed = init_sources();
	ASSERT_NE(compressed, nullptr);

	byte_decompression(compressed, masks, &output[0][0], M);

	size_t counter = 0;
	for (size_t i = 0; i < M; i++) {
		for (unsigned int j = 0; j < 64; j++) {
			if (masks[i] & (static_cast<uint64_t>(1) << j)) {
				ASSERT_EQ(compressed[counter++], output[i][j]);
			} else {
				ASSERT_EQ(0, output[i][j]);
			}
		}
	}
	_mm_free(compressed);
}
