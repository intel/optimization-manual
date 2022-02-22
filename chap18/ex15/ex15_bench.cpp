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

#include "memory_broadcast.h"
#include "register_broadcast.h"

const size_t MAX_OUTPUTS = 32;

#ifdef _MSC_VER
__declspec(align(64)) static uint16_t indices[MAX_OUTPUTS];
__declspec(align(64)) static uint16_t input[MAX_OUTPUTS];
__declspec(align(64)) static uint16_t output[MAX_OUTPUTS];
#else
static uint16_t indices[MAX_OUTPUTS] __attribute__((aligned(64)));
static uint16_t input[MAX_OUTPUTS] __attribute__((aligned(64)));
static uint16_t output[MAX_OUTPUTS] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_OUTPUTS; i++) {
		indices[i] = (uint16_t)((MAX_OUTPUTS - 1) - i);
		input[i] = (uint16_t)i;
		output[i] = (uint16_t)0;
	}
}

static void BM_Register_broadcast(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);
	uint32_t *broadcast_values =
	    (uint32_t *)malloc(sizeof(*broadcast_values) * len);

	init_sources();

	for (int i = 0; i < len; i++)
		broadcast_values[i] = (uint16_t)(i + 1);

	for (auto _ : state) {
		register_broadcast(input, output, len, broadcast_values,
				   indices);
	}

	free(broadcast_values);
}

static void BM_Memory_broadcast(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);
	uint16_t *broadcast_values_16 =
	    (uint16_t *)malloc(sizeof(*broadcast_values_16) * len);

	init_sources();

	for (int i = 0; i < len; i++)
		broadcast_values_16[i] = (uint16_t)(i + 1);

	for (auto _ : state) {
		memory_broadcast(input, output, len, broadcast_values_16,
				 indices);
	}

	free(broadcast_values_16);
}

BENCHMARK(BM_Register_broadcast)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_Memory_broadcast)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
