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

#include <benchmark/benchmark.h>
#include <stdint.h>
#include <string.h>
#include <xmmintrin.h>

#include "dotprod_novnni.h"
#include "dotprod_vnni.h"
#include "optimisation_common.h"

#define M 64
#define K 64
#define N 64
#define K_PACKED (K / 4)
#define N_PACKED (N * 4)

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static uint8_t lhs[M][K];
__declspec(align(64)) static int8_t rhs_packed[K_PACKED][N_PACKED];
__declspec(align(64)) static int32_t res[M][N];
#else
static uint8_t lhs[M][K] __attribute__((aligned(64)));
static int8_t rhs_packed[K_PACKED][N_PACKED] __attribute__((aligned(64)));
static int32_t res[M][N] __attribute__((aligned(64)));
#endif

static void init_data()
{
	int8_t counter = 0;

	memset(res, 0, sizeof(res));

	for (size_t j = 0; j < M; j++)
		for (size_t k = 0; k < K; k++)
			lhs[j][k] = (counter++) & 127;

	counter = 0;
	for (size_t j = 0; j < K_PACKED; j++)
		for (size_t k = 0; k < N_PACKED; k++)
			rhs_packed[j][k] = (counter++) & 127;
}

static void BM_dotprod_novnni(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	init_data();
	for (auto _ : state) {
		for (size_t i = 0; i < 16; i++)
			dotprod_novnni_4x64x64(
			    &lhs[i * 4][0], &rhs_packed[0][0], &res[i * 4][0]);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(sizeof(lhs) + sizeof(rhs_packed)));
}

static void BM_vnni(benchmark::State &state)
{
	if (!supports_avx512_clx()) {
		state.SkipWithError("VNNI not supported, skipping test");
		return;
	}

	init_data();
	for (auto _ : state) {
		for (size_t i = 0; i < 16; i++)
			dotprod_vnni_4x64x64(&lhs[i * 4][0], &rhs_packed[0][0],
					     &res[i * 4][0]);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(sizeof(lhs) + sizeof(rhs_packed)));
}

BENCHMARK(BM_dotprod_novnni);
BENCHMARK(BM_vnni);
BENCHMARK_MAIN();
