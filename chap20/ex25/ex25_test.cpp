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

#include "flat_to_vnni_bf16_relayout.h"
#include "optimisation_common.h"

#define M 4
#define N 96
#define K_PACK 2
#define OM (M / K_PACK)
#define ON (N * K_PACK)

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

TEST(amx_25, amx_vnni_to_vnni_bf16_relayout)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();

	flat_to_vnni_bf16_relayout(&input[0][0], &output[0][0]);

	for (size_t i = 0; i < M; i++) {
		for (size_t j = 0; j < N; j++) {
			ASSERT_EQ(
			    input[i][j],
			    output[i / K_PACK][(j * K_PACK) + i % K_PACK]);
		}
	}
}
