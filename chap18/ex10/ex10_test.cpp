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

#include "avx2_compress.h"
#include "avx512_compress.h"
#include "avx_compress.h"
#include "optimisation_common.h"
#include "scalar_compress.h"

const size_t MAX_SIZE = 4096;

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t in[MAX_SIZE];
__declspec(align(64)) static uint32_t c_out[MAX_SIZE];
__declspec(align(64)) static uint32_t asm_out[MAX_SIZE];
#else
static uint32_t in[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t c_out[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t asm_out[MAX_SIZE] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	uint32_t counter = 0;
	for (size_t i = 0; i < MAX_SIZE; i += 2048) {
		for (size_t j = 0; j < 256; j++) {
			if (j & 1)
				in[i + (j * 8)] = counter++;
			if (j & 2)
				in[i + (j * 8) + 1] = counter++;
			if (j & 4)
				in[i + (j * 8) + 2] = counter++;
			if (j & 8)
				in[i + (j * 8) + 3] = counter++;
			if (j & 16)
				in[i + (j * 8) + 4] = counter++;
			if (j & 32)
				in[i + (j * 8) + 5] = counter++;
			if (j & 64)
				in[i + (j * 8) + 6] = counter++;
			if (j & 128)
				in[i + (j * 8) + 7] = counter++;
		}
	}
}

static uint64_t compress(uint32_t *b, const uint32_t *a, size_t SIZE)
{
	uint64_t j = 0;

	for (size_t i = 0; i < SIZE; i++) {
		if (a[i] > 0)
			b[j++] = a[i];
	}

	return j;
}

TEST(avx512_10, scalar_compress)
{
	uint64_t c_out_len;
	uint64_t asm_out_len;

	init_sources();
	memset(asm_out, 0, sizeof(asm_out));

	c_out_len = compress(c_out, in, MAX_SIZE);
	ASSERT_EQ(scalar_compress_check(asm_out, in, MAX_SIZE, &asm_out_len),
		  true);

	ASSERT_EQ(c_out_len, asm_out_len);
	for (size_t i = 0; i < c_out_len; i++) {
		ASSERT_EQ(c_out[i], asm_out[i]);
	}

	ASSERT_EQ(scalar_compress_check(NULL, in, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(scalar_compress_check(asm_out, NULL, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(scalar_compress_check(asm_out, in, 0, &asm_out_len), false);
}

TEST(avx512_10, avx_compress)
{
	uint64_t c_out_len;
	uint64_t asm_out_len;

	init_sources();
	memset(asm_out, 0, sizeof(asm_out));

	c_out_len = compress(c_out, in, MAX_SIZE);
	ASSERT_EQ(avx_compress_check(asm_out, in, MAX_SIZE, &asm_out_len),
		  true);

	ASSERT_EQ(c_out_len, asm_out_len);
	for (size_t i = 0; i < c_out_len; i++) {
		ASSERT_EQ(c_out[i], asm_out[i]);
	}

	ASSERT_EQ(avx_compress_check(NULL, in, MAX_SIZE, &asm_out_len), false);
	ASSERT_EQ(avx_compress_check(asm_out, NULL, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(avx_compress_check(asm_out, in + 2, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(avx_compress_check(asm_out, in, MAX_SIZE - 2, &asm_out_len),
		  false);
}

TEST(avx512_10, avx2_compress)
{
	uint64_t c_out_len;
	uint64_t asm_out_len;

	init_sources();
	memset(asm_out, 0, sizeof(asm_out));

	c_out_len = compress(c_out, in, MAX_SIZE);
	ASSERT_EQ(avx2_compress_check(asm_out, in, MAX_SIZE, &asm_out_len),
		  true);

	ASSERT_EQ(c_out_len, asm_out_len);
	for (size_t i = 0; i < c_out_len; i++) {
		ASSERT_EQ(c_out[i], asm_out[i]);
	}

	ASSERT_EQ(avx2_compress_check(NULL, in, MAX_SIZE, &asm_out_len), false);
	ASSERT_EQ(avx2_compress_check(asm_out, NULL, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(avx2_compress_check(asm_out, in + 4, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(avx2_compress_check(asm_out, in, MAX_SIZE - 4, &asm_out_len),
		  false);
}

TEST(avx512_10, avx512_compress)
{
	uint64_t c_out_len;
	uint64_t asm_out_len;

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	memset(asm_out, 0, sizeof(asm_out));

	c_out_len = compress(c_out, in, MAX_SIZE);
	ASSERT_EQ(avx512_compress_check(asm_out, in, MAX_SIZE, &asm_out_len),
		  true);

	ASSERT_EQ(c_out_len, asm_out_len);
	for (size_t i = 0; i < c_out_len; i++) {
		ASSERT_EQ(c_out[i], asm_out[i]);
	}

	ASSERT_EQ(avx512_compress_check(NULL, in, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(avx512_compress_check(asm_out, NULL, MAX_SIZE, &asm_out_len),
		  false);
	ASSERT_EQ(
	    avx512_compress_check(asm_out, in + 8, MAX_SIZE, &asm_out_len),
	    false);
	ASSERT_EQ(
	    avx512_compress_check(asm_out, in, MAX_SIZE - 8, &asm_out_len),
	    false);
}
