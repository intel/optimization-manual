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

#include "hardware_scatter.h"
#include "scalar_scatter.h"
#include "software_scatter.h"

static void init_sources(uint64_t *input, uint32_t *indices, int len)
{
	for (int i = 0; i < len; i++) {
		indices[i] = (uint32_t)i * 4;
		input[i] = (uint64_t)rand();
	}
}

static void BM_scatter_scalar(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint64_t *input = (uint64_t *)malloc(len * sizeof(*input));
	uint32_t *indices = (uint32_t *)malloc(len * sizeof(*indices));
	float *output = (float *)malloc(len * sizeof(*output) * 4);

	init_sources(input, indices, len);

	for (auto _ : state) {
		scalar_scatter(input, indices, len * 4, output);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(input[0])));

	free(output);
	free(indices);
	free(input);
}

static void BM_scatter_software(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint64_t *input = (uint64_t *)_mm_malloc(len * sizeof(*input), 64);
	uint32_t *indices = (uint32_t *)_mm_malloc(len * sizeof(*indices), 64);
	float *output = (float *)_mm_malloc(len * sizeof(*output) * 4, 64);

	init_sources(input, indices, len);

	for (auto _ : state) {
		software_scatter(input, indices, len * 4, output);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(input[0])));

	_mm_free(output);
	_mm_free(indices);
	_mm_free(input);
}

static void BM_scatter_hardware(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint64_t *input = (uint64_t *)_mm_malloc(len * sizeof(*input), 64);
	uint32_t *indices = (uint32_t *)_mm_malloc(len * sizeof(*indices), 64);
	float *output = (float *)_mm_malloc(len * sizeof(*output) * 4, 64);

	init_sources(input, indices, len);

	for (auto _ : state) {
		hardware_scatter(input, indices, len * 4, output);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(input[0])));

	_mm_free(output);
	_mm_free(indices);
	_mm_free(input);
}

BENCHMARK(BM_scatter_scalar)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_scatter_software)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_scatter_hardware)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
