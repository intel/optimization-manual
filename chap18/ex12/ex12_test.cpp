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
#include <cstdlib>

#include "optimisation_common.h"
#include "ternary_avx2.h"
#include "ternary_avx512.h"
#include "ternary_vpternlog.h"

const size_t MAX_SIZE = 4096;

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t a[MAX_SIZE];
__declspec(align(64)) static uint32_t b[MAX_SIZE];
__declspec(align(64)) static uint32_t c[MAX_SIZE];
__declspec(align(64)) static uint32_t asm_dest[MAX_SIZE];
#else
static uint32_t a[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t b[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t c[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t asm_dest[MAX_SIZE] __attribute__((aligned(64)));
#endif
static uint32_t dest[MAX_SIZE];

static void ternary_scalar(uint32_t *dest, const uint32_t *src1,
			   const uint32_t *src2, const uint32_t *src3,
			   size_t SIZE)
{
	for (size_t i = 0; i < SIZE; i++) {
		dest[i] = ((~src2[i]) & (src1[i] ^ src3[i])) |
			  (src1[i] & src2[i] & src3[i]);
	}
}

static void init_sources()
{
	srand(0);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = std::rand() & 1;
		b[i] = std::rand() & 1;
		c[i] = std::rand() & 1;
	}
	ternary_scalar(dest, a, b, c, MAX_SIZE);
}

TEST(avx512_12, avx2_ternary)
{
	init_sources();
	memset(asm_dest, 0, sizeof(asm_dest));
	ternary_avx2(asm_dest, a, b, c, MAX_SIZE);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(dest[i], asm_dest[i]);
	}
}

TEST(avx512_12, avx512_ternary)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	memset(asm_dest, 0, sizeof(asm_dest));
	ternary_avx512(asm_dest, a, b, c, MAX_SIZE);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(dest[i], asm_dest[i]);
	}
}

TEST(avx512_12, vpternlog_ternary)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	memset(asm_dest, 0, sizeof(asm_dest));
	ternary_vpternlog(asm_dest, a, b, c, MAX_SIZE);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(dest[i], asm_dest[i]);
	}
}
