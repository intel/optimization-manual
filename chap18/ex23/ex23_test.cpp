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
#include <stdint.h>

#include "decompress_novbmi.h"
#include "decompress_vbmi.h"
#include "optimisation_common.h"

/*
 * Input and output values have been chosen so that they are both
 * divisible by 64.  The final iteration of the loop will read
 * 24 bytes that will not actually be used.  Let's ensure our
 * input buffer is large enough and contains 0s for these bytes.
 */

const int MAX_INPUT_SIZE = 320;
const int MAX_INPUT_BUFFER_SIZE = 280 + 64;
const int MAX_OUTPUT_SIZE = 512;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static unsigned char a[MAX_INPUT_BUFFER_SIZE];
__declspec(align(64)) static unsigned char c_out[MAX_OUTPUT_SIZE];
__declspec(align(64)) static unsigned char out[MAX_OUTPUT_SIZE];
#else
static unsigned char a[MAX_INPUT_BUFFER_SIZE] __attribute__((aligned(64)));
static unsigned char c_out[MAX_OUTPUT_SIZE] __attribute__((aligned(64)));
static unsigned char out[MAX_OUTPUT_SIZE] __attribute__((aligned(64)));
#endif
void init_sources()
{
	for (size_t i = 0; i < MAX_INPUT_SIZE; i++) {
		a[i] = static_cast<uint8_t>(i % 255);
	}
	for (size_t i = MAX_INPUT_SIZE; i < MAX_INPUT_BUFFER_SIZE; i++) {
		a[i] = 0;
	}
	for (size_t i = 0; i < MAX_OUTPUT_SIZE; i++) {
		out[i] = 0;
	}
}

void decompress(unsigned char *compressedData, unsigned char *decompressedData,
		int numOfElements)
{
	for (int i = 0; i < numOfElements; i += 8) {
		uint64_t *data = (uint64_t *)compressedData;
		decompressedData[i + 0] = *data & 0x1f;
		decompressedData[i + 1] = (*data >> 5) & 0x1f;
		decompressedData[i + 2] = (*data >> 10) & 0x1f;
		decompressedData[i + 3] = (*data >> 15) & 0x1f;
		decompressedData[i + 4] = (*data >> 20) & 0x1f;
		decompressedData[i + 5] = (*data >> 25) & 0x1f;
		decompressedData[i + 6] = (*data >> 30) & 0x1f;
		decompressedData[i + 7] = (*data >> 35) & 0x1f;
		compressedData += 5;
	}
}

TEST(avx512_23, decompress_novbmi)
{
	init_sources();
	decompress(a, c_out, MAX_OUTPUT_SIZE);
	ASSERT_EQ(decompress_novbmi_check(MAX_OUTPUT_SIZE, out, a), true);
	for (size_t i = 0; i < MAX_OUTPUT_SIZE; i++) {
		ASSERT_EQ(c_out[i], out[i]);
	}
	ASSERT_EQ(decompress_novbmi_check(MAX_OUTPUT_SIZE - 4, out, a), false);
	ASSERT_EQ(decompress_novbmi_check(MAX_OUTPUT_SIZE, NULL, a), false);
	ASSERT_EQ(decompress_novbmi_check(MAX_OUTPUT_SIZE, out, NULL), false);
}

TEST(avx512_23, decompress_vbmi)
{
	if (!supports_avx512_icl())
		GTEST_SKIP_("VBMI not supported, skipping test");

	init_sources();
	decompress(a, c_out, MAX_OUTPUT_SIZE);
	ASSERT_EQ(decompress_vbmi_check(out, a, MAX_OUTPUT_SIZE), true);
	for (size_t i = 0; i < MAX_OUTPUT_SIZE; i++) {
		ASSERT_EQ(c_out[i], out[i]);
	}
	ASSERT_EQ(decompress_vbmi_check(NULL, a, MAX_OUTPUT_SIZE), false);
	ASSERT_EQ(decompress_vbmi_check(out, NULL, MAX_OUTPUT_SIZE), false);
	ASSERT_EQ(decompress_vbmi_check(out, a, MAX_OUTPUT_SIZE - 32), false);
}
