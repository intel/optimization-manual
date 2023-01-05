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

#include "optimisation_common.h"
#include "vnni_to_vnni_bf16_trans.h"

#define M 32
#define N 8
#define OM 4
#define ON 64
#define K_PACK 2

alignas(64) static bfloat_16 input[M / K_PACK][N * K_PACK];
alignas(64) static bfloat_16 output[OM][ON];
alignas(64) static bfloat_16 expected[OM][ON];

static void init_sources()
{
	float val = 0;
	for (size_t i = 0; i < M; i++) {
		for (size_t j = 0; j < N; j++) {
			memcpy(&input[i / K_PACK][(j * K_PACK) + (i % K_PACK)],
			       &reinterpret_cast<uint16_t *>(&val)[1],
			       sizeof(bfloat_16));
			val += 1.0;
		}
	}

	val = 0;

	for (size_t i = 0; i < ON / K_PACK; i++) {
		for (size_t j = 0; j < OM; j++) {
			for (size_t k = 0; k < K_PACK; k++) {
				memcpy(&expected[j][i * K_PACK + k],
				       &reinterpret_cast<uint16_t *>(&val)[1],
				       sizeof(bfloat_16));
				val += 1.0;
			}
		}
	}
}

TEST(amx_23, amx_vnni_to_vnni_bf16_trans)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	vnni_to_vnni_bf16_trans(&input[0][0], &output[0][0]);

	for (size_t i = 0; i < OM; i++) {
		for (size_t j = 0; j < ON; j++) {
			ASSERT_EQ(output[i][j], expected[i][j]);
		}
	}
}
