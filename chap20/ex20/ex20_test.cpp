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

#include "int8_conv_test.h"
#include "optimisation_common.h"

#define MAX_VECS 4
#define MAX_ELEMENTS (MAX_VECS * 16)

alignas(64) static uint32_t dwords[MAX_ELEMENTS];
static __m512i vecs[MAX_VECS];

TEST(amx_20, amx_conv_block_int8)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	int8_conv_init(dwords, MAX_ELEMENTS, vecs, MAX_VECS);

	alignas(64) uint8_t bytes[MAX_ELEMENTS];
	int8_conv_pack_dwords_to_bytes(vecs, bytes);

	for (size_t i = 0; i < MAX_ELEMENTS; i++) {
		if (dwords[i] > 255)
			ASSERT_EQ(bytes[i], 255);
		else
			ASSERT_EQ(bytes[i], static_cast<uint8_t>(dwords[i]));
	}
}
