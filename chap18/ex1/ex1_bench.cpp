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
#include <xmmintrin.h>

#include "optimisation_common.h"

#include "transform_avx.h"
#include "transform_avx512.h"

static void BM_transform_avx(benchmark::State &state)
{
	int len = state.range(0);
	// Dynamic memory allocation with 32byte
	// alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 32);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 32);
	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;
	float cos_teta = 0.8660254037;
	float sin_teta = 0.5;

	for (auto _ : state) {
		transform_avx(sin_teta, cos_teta, pInVector, pOutVector, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(pInVector[0])));

	_mm_free(pInVector);
	_mm_free(pOutVector);
}

static void BM_transform_avx512(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);
	// Dynamic memory allocation with 64byte
	// alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 64);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 64);
	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;
	float cos_teta = 0.8660254037;
	float sin_teta = 0.5;

	for (auto _ : state) {
		transform_avx512(sin_teta, cos_teta, pInVector, pOutVector,
				 len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(pInVector[0])));

	_mm_free(pInVector);
	_mm_free(pOutVector);
}

BENCHMARK(BM_transform_avx)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_transform_avx512)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
