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

#include <benchmark/benchmark.h>
#include <xmmintrin.h>

#include "vblendps_transpose.h"
#include "vshufps_transpose.h"

const int MAX_SIZE = 8; /* Must be 8 */

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float x[MAX_SIZE][MAX_SIZE];
__declspec(align(32)) static float y[MAX_SIZE][MAX_SIZE];
#else
static float x[MAX_SIZE][MAX_SIZE] __attribute__((aligned(32)));
static float y[MAX_SIZE][MAX_SIZE] __attribute__((aligned(32)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++)
		for (size_t j = 0; j < MAX_SIZE; j++) {
			x[i][j] = (float)i * MAX_SIZE + j;
		}
}

static void BM_vshufps_transpose(benchmark::State &state)
{
	int len = state.range(0);

	init_sources();

	for (auto _ : state) {
		vshufps_transpose(x, y, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(float) * MAX_SIZE * MAX_SIZE));
}

static void BM_blendps_transpose(benchmark::State &state)
{
	int len = state.range(0);

	init_sources();

	for (auto _ : state) {
		vblendps_transpose(x, y, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(float) * MAX_SIZE * MAX_SIZE));
}

BENCHMARK(BM_vshufps_transpose)
    ->Arg(1 << 4)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12);
BENCHMARK(BM_blendps_transpose)
    ->Arg(1 << 4)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12);
BENCHMARK_MAIN();
