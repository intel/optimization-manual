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

#include "embedded_broadcast.h"
#include "memory_broadcast.h"
#include "register_broadcast.h"

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t indices[16];
__declspec(align(64)) static uint32_t input[16];
__declspec(align(64)) static uint32_t output[16];
#else
static uint32_t indices[16] __attribute__((aligned(64)));
static uint32_t input[16] __attribute__((aligned(64)));
static uint32_t output[16] __attribute__((aligned(64)));
#endif

static void init_sources(uint32_t *broadcast_values, int len)
{
	for (uint32_t i = 0; i < 16; i++)
		indices[i] = 15 - i;
	for (uint32_t i = 0; i < (uint32_t)len; i++)
		broadcast_values[i] = i + 1;
	for (uint32_t i = 0; i < 16; i++) {
		input[i] = i;
		output[i] = 0;
	}
}

static void BM_register_broadcast(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint32_t *broadcast = (uint32_t *)malloc(len * sizeof(*broadcast));

	init_sources(broadcast, len);

	for (auto _ : state) {
		register_broadcast(input, output, (uint64_t)len, broadcast,
				   indices);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(broadcast[0])));

	free(broadcast);
}

static void BM_memory_broadcast(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint32_t *broadcast = (uint32_t *)malloc(len * sizeof(*broadcast));

	init_sources(broadcast, len);

	for (auto _ : state) {
		memory_broadcast(input, output, (uint64_t)len, broadcast,
				 indices);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(broadcast[0])));

	free(broadcast);
}

static void BM_embedded_broadcast(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint32_t *broadcast = (uint32_t *)malloc(len * sizeof(*broadcast));

	init_sources(broadcast, len);

	for (auto _ : state) {
		embedded_broadcast(input, output, (uint64_t)len, broadcast,
				   indices);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(broadcast[0])));

	free(broadcast);
}

BENCHMARK(BM_register_broadcast)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_memory_broadcast)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_embedded_broadcast)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
