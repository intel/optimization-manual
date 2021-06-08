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

#include "klt_256.h"

const int MAX_SIZE = 64;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static short in[MAX_SIZE][MAX_SIZE];
__declspec(align(32)) static short out[MAX_SIZE][MAX_SIZE];
#else
static short in[MAX_SIZE][MAX_SIZE] __attribute__((aligned(32)));
static short out[MAX_SIZE][MAX_SIZE] __attribute__((aligned(32)));
#endif

// clang-format off

static short rmc[4][4] = {
    {64, 64, 64, 64},
    {84, 35, -35, -84},
    {64, -64, -64, 64},
    {35, -84, 84, -35},
};

static short lmr[4][4] = {
    {29, 55, 74, 84},
    {74, 74, 0, -74},
    {84, -29, -74, 55},
    {55, -84, 74, -29},
};

// clang-format on

static void init_sources()
{
	for (int i = 0; i < MAX_SIZE; i++) {
		for (int j = 0; j < MAX_SIZE; j++) {
			in[i][j] = (i * MAX_SIZE) + j;
			out[i][j] = 0;
		}
	}
}

static void compute_4x4_matrix(size_t x, size_t y, int32_t out[][4])
{
	int32_t tmp[4][4];

	memset(tmp, 0, sizeof(int32_t) * 4 * 4);
	memset(out, 0, sizeof(int32_t) * 4 * 4);

	for (size_t i = 0; i < 4; i++)
		for (size_t j = 0; j < 4; j++) {
			for (size_t k = 0; k < 4; k++) {
				tmp[i][j] += in[y + i][x + k] * rmc[k][j];
			}
		}

	for (size_t i = 0; i < 4; i++)
		for (size_t j = 0; j < 4; j++) {
			tmp[i][j] /= 128;
			if (tmp[i][j] > 0x7fff)
				tmp[i][j] = 0x7fff;
		}

	for (size_t i = 0; i < 4; i++)
		for (size_t j = 0; j < 4; j++) {
			for (size_t k = 0; k < 4; k++) {
				out[i][j] += lmr[i][k] * tmp[k][j];
			}
		}

	for (size_t i = 0; i < 4; i++)
		for (size_t j = 0; j < 4; j++) {
			out[i][j] /= 128;
			if (out[i][j] > 0x7fff)
				out[i][j] = 0x7fff;
		}
}

TEST(avx_39, klt_256d)
{
	init_sources();
	ASSERT_EQ(klt_256_d_check(&in[0][0], &out[0][0], MAX_SIZE, MAX_SIZE),
		  true);

	for (size_t i = 0; i < MAX_SIZE; i += 4)
		for (size_t j = 0; j < MAX_SIZE; j += 4) {
			int32_t tmp[4][4];
			compute_4x4_matrix(j, i, tmp);
			for (size_t k = 0; k < 4; k++) {
				for (size_t l = 0; l < 4; l++) {
					ASSERT_EQ(tmp[k][l], out[i + k][j + l]);
				}
			}
		}

	ASSERT_EQ(klt_256_d_check(NULL, &out[0][0], MAX_SIZE, MAX_SIZE), false);
	ASSERT_EQ(klt_256_d_check(&in[0][0], NULL, MAX_SIZE, MAX_SIZE), false);
	ASSERT_EQ(klt_256_d_check(&in[0][0], &out[0][0], 8, MAX_SIZE), false);
	ASSERT_EQ(klt_256_d_check(&in[0][0], &out[0][0], MAX_SIZE, 2), false);
	ASSERT_EQ(
	    klt_256_d_check(&in[0][0], &out[0][0] + 1, MAX_SIZE, MAX_SIZE),
	    false);
	ASSERT_EQ(klt_256_d_check(&in[0][0], &out[0][0], 0, MAX_SIZE), true);
	ASSERT_EQ(klt_256_d_check(&in[0][0], &out[0][0], MAX_SIZE, 0), true);
}
