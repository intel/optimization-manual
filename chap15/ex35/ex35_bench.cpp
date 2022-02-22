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

#include "fp_fma.h"
#include "fp_mul_add.h"

const int MAX_SIZE = 8;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float a[MAX_SIZE];
__declspec(align(32)) static float c1[MAX_SIZE];
__declspec(align(32)) static float c2[MAX_SIZE];
#else
static float a[MAX_SIZE] __attribute__((aligned(32)));
static float c1[MAX_SIZE] __attribute__((aligned(32)));
static float c2[MAX_SIZE] __attribute__((aligned(32)));
#endif

static void init_sources()
{
	for (int i = 0; i < MAX_SIZE; i++) {
		a[i] = i * 1.0f;
		c1[i] = i * 2.0f;
		c2[i] = i * 4.0f;
	}
}

static void BM_fp_mul_add(benchmark::State &state)
{
	int iters = state.range(0);

	init_sources();

	for (auto _ : state) {
		fp_mul_add(a, c1, c2, iters);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(MAX_SIZE) * int64_t(sizeof(*a) * 3));
}

static void BM_fp_fma(benchmark::State &state)
{
	int iters = state.range(0);

	init_sources();

	for (auto _ : state) {
		fp_fma(a, c1, c2, iters);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(MAX_SIZE) * int64_t(sizeof(*a) * 3));
}

BENCHMARK(BM_fp_mul_add)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_fp_fma)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
