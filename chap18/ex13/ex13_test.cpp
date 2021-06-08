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

#include "optimisation_common.h"
#include "transpose_avx2.h"
#include "transpose_avx512.h"
#include "transpose_scalar.h"

const size_t MATRIX_W = 8;
const size_t MATRIX_H = 8;
const size_t MATRIX_COUNT = 50;

#ifdef _MSC_VER
__declspec(align(64)) static uint16_t in[MATRIX_COUNT * MATRIX_W * MATRIX_H];
__declspec(
    align(64)) static uint16_t asm_out[MATRIX_COUNT * MATRIX_W * MATRIX_H];
#else
static uint16_t in[MATRIX_COUNT * MATRIX_W * MATRIX_H]
    __attribute__((aligned(64)));
static uint16_t asm_out[MATRIX_COUNT * MATRIX_W * MATRIX_H]
    __attribute__((aligned(64)));
#endif

uint16_t out[MATRIX_COUNT * MATRIX_W * MATRIX_H];

static void init_sources()
{
	uint16_t counter = 0;
	for (size_t i = 0; i < MATRIX_COUNT; i++)
		for (size_t j = 0; j < MATRIX_H; j++)
			for (size_t k = 0; k < MATRIX_W; k++) {
				in[counter] = counter;
				counter++;
			}

	size_t start = 0;
	for (size_t i = 0; i < MATRIX_COUNT; i++) {
		for (size_t j = 0; j < MATRIX_H; j++)
			for (size_t k = 0; k < MATRIX_W; k++)
				out[start + (j * MATRIX_H) + k] =
				    in[start + (k * MATRIX_W) + j];
		start += MATRIX_H * MATRIX_W;
	}
}

TEST(avx512_13, transpose_scalar)
{
	init_sources();
	memset(asm_out, 0, sizeof(asm_out));
	ASSERT_EQ(transpose_scalar_check(asm_out, in), true);

	size_t counter = 0;
	for (size_t i = 0; i < MATRIX_COUNT; i++)
		for (size_t j = 0; j < MATRIX_H; j++)
			for (size_t k = 0; k < MATRIX_W; k++) {
				ASSERT_EQ(out[counter], asm_out[counter]);
				counter++;
			}

	ASSERT_EQ(transpose_scalar_check(NULL, in), false);
	ASSERT_EQ(transpose_scalar_check(asm_out, NULL), false);
}

TEST(avx512_13, transpose_avx2)
{
	init_sources();
	memset(asm_out, 0, sizeof(asm_out));
	ASSERT_EQ(transpose_avx2_check(asm_out, in), true);

	size_t counter = 0;
	for (size_t i = 0; i < MATRIX_COUNT; i++)
		for (size_t j = 0; j < MATRIX_H; j++)
			for (size_t k = 0; k < MATRIX_W; k++) {
				ASSERT_EQ(out[counter], asm_out[counter]);
				counter++;
			}

	ASSERT_EQ(transpose_avx2_check(NULL, in), false);
	ASSERT_EQ(transpose_avx2_check(asm_out, NULL), false);
	ASSERT_EQ(transpose_avx2_check(asm_out + 8, in), false);
	ASSERT_EQ(transpose_avx2_check(asm_out, in + 8), false);
}

TEST(avx512_13, transpose_avx512)
{

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	memset(asm_out, 0, sizeof(asm_out));
	ASSERT_EQ(transpose_avx512_check(asm_out, in), true);

	size_t counter = 0;
	for (size_t i = 0; i < MATRIX_COUNT; i++)
		for (size_t j = 0; j < MATRIX_H; j++)
			for (size_t k = 0; k < MATRIX_W; k++) {
				ASSERT_EQ(out[counter], asm_out[counter]);
				counter++;
			}

	ASSERT_EQ(transpose_avx512_check(NULL, in), false);
	ASSERT_EQ(transpose_avx512_check(asm_out, NULL), false);
	ASSERT_EQ(transpose_avx512_check(asm_out + 16, in), false);
	ASSERT_EQ(transpose_avx512_check(asm_out, in + 16), false);
}
