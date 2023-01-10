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

#include "flat_to_vnni_bf16_trans.h"
#include "optimisation_common.h"

#define M 64
#define N 16
#define OM 8
#define ON 128

alignas(64) static bfloat_16 input[M][N];
alignas(64) static bfloat_16 output[OM][ON];

static void init_sources()
{
	float val = 0;
	for (size_t i = 0; i < M; i++) {
		for (size_t j = 0; j < N; j++) {
			memcpy(&input[i][j],
			       &reinterpret_cast<uint16_t *>(&val)[1],
			       sizeof(bfloat_16));
			val += 1.0;
		}
	}
}

TEST(amx_24, amx_vnni_to_vnni_bf16_trans)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	flat_to_vnni_bf16_trans(&input[0][0], &output[0][0]);

	for (size_t i = 0; i < OM; i++) {
		for (size_t j = 0; j < M; j++) {
			ASSERT_EQ(input[j][i * 2], output[i][j * 2]);
			ASSERT_EQ(input[j][i * 2 + 1], output[i][j * 2 + 1]);
		}
	}
}
