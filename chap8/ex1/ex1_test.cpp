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

#include <stdint.h>
#include <string.h>
#include <xmmintrin.h>

#include "gtest/gtest.h"

#include "dotprod_novnni.h"
#include "dotprod_vnni.h"
#include "optimisation_common.h"

#define M 64
#define K 64
#define N 64
#define K_PACKED (K / 4)
#define N_PACKED (N * 4)

static uint8_t lhs[M][K];
static int8_t rhs[K][N];
static int8_t rhs_packed[K_PACKED][N_PACKED];
static int32_t res_scalar[M][N];
static int32_t res[M][N];

static void init_data()
{
	int8_t counter = 0;

	memset(res, 0, sizeof(res));
	memset(res_scalar, 0, sizeof(res_scalar));

	for (size_t j = 0; j < M; j++)
		for (size_t k = 0; k < K; k++)
			lhs[j][k] = (counter++) & 127;

	counter = 0;
	for (size_t j = 0; j < K; j++)
		for (size_t k = 0; k < N; k++)
			rhs[j][k] = (counter++) & 127;

	for (size_t j = 0; j < K; j += 4) {
		for (size_t k = 0; k < N; k++) {
			rhs_packed[j / 4][(k * 4)] = rhs[j][k];
			rhs_packed[j / 4][(k * 4) + 1] = rhs[j + 1][k];
			rhs_packed[j / 4][(k * 4) + 2] = rhs[j + 2][k];
			rhs_packed[j / 4][(k * 4) + 3] = rhs[j + 3][k];
		}
	}

	for (size_t i = 0; i < M; i++)
		for (size_t j = 0; j < N; j++)
			for (size_t p = 0; p < K; p++)
				res_scalar[i][j] +=
				    static_cast<int32_t>(lhs[i][p]) *
				    static_cast<int32_t>(rhs[p][j]);
}

TEST(vnni, dotprod_novnni)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_data();
	for (size_t i = 0; i < 16; i++)
		dotprod_novnni_4x64x64(&lhs[i * 4][0], &rhs_packed[0][0],
				       &res[i * 4][0]);

	for (int i = 0; i < M; i++)
		for (int j = 0; j < N; j++) {
			ASSERT_EQ(res[i][j], res_scalar[i][j]);
		}
}

TEST(vnni, dotprod_vnni)
{
	if (!supports_avx512_clx())
		GTEST_SKIP_("VNNI not supported, skipping test");

	init_data();
	for (size_t i = 0; i < 16; i++)
		dotprod_vnni_4x64x64(&lhs[i * 4][0], &rhs_packed[0][0],
				     &res[i * 4][0]);

	for (int i = 0; i < M; i++)
		for (int j = 0; j < N; j++) {
			ASSERT_EQ(res[i][j], res_scalar[i][j]);
		}
}
