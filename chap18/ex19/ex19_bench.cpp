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
#include <string.h>
#include <xmmintrin.h>

#include "optimisation_common.h"

#include "avx512_histogram.h"
#include "scalar_histogram.h"

const size_t MAX_BINS = 32;

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t histogram[MAX_BINS];
#else
static uint32_t histogram[MAX_BINS] __attribute__((aligned(64)));
#endif

static void init_sources(int32_t *inputs, int len)
{
	for (int i = 0; i < len; i++)
		inputs[i] = rand();
	memset(histogram, 0, sizeof(histogram));
}

static void BM_scalar_histogram(benchmark::State &state)
{
	int len = state.range(0);

	int32_t *inputs = (int32_t *)malloc(len * sizeof(*inputs));

	init_sources(inputs, len);

	for (auto _ : state) {
		scalar_histogram(inputs, histogram, len, MAX_BINS);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(inputs[0])));

	free(inputs);
}

static void BM_avx512_histogram(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	int32_t *inputs = (int32_t *)_mm_malloc(len * sizeof(*inputs), 64);

	init_sources(inputs, len);

	for (auto _ : state) {
		avx512_histogram(inputs, histogram, len, MAX_BINS);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(inputs[0])));

	_mm_free(inputs);
}

BENCHMARK(BM_scalar_histogram)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx512_histogram)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
