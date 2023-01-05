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

#include "mul_mask_avx512.h"
#include "mul_nomask_avx512.h"
#include "mul_zeromask_avx512.h"
#include "optimisation_common.h"

const size_t MAX_SIZE = 16;

static void init_sources(float *a, float *b, float *out1, float *out2)
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = (float)i;
		b[i] = 2.0;
		out1[i] = 1.0;
		out2[i] = 1.0;
	}
}

static void BM_mul_nomask_avx512(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	size_t iterations = state.range(0);
	float *a = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *b = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *out1 = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *out2 = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);

	init_sources(a, b, out1, out2);
	for (auto _ : state) {
		mul_nomask_avx512(a, b, out1, out2, iterations);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(MAX_SIZE) * 2 * int64_t(sizeof(a[0])));

	_mm_free(out2);
	_mm_free(out1);
	_mm_free(b);
	_mm_free(a);
}

static void BM_mul_mask_avx512(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	size_t iterations = state.range(0);
	float *a = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *b = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *out1 = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *out2 = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);

	init_sources(a, b, out1, out2);
	for (auto _ : state) {
		mul_mask_avx512(a, b, out1, out2, iterations);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(MAX_SIZE) * 2 * int64_t(sizeof(a[0])));

	_mm_free(out2);
	_mm_free(out1);
	_mm_free(b);
	_mm_free(a);
}

static void BM_mul_zeromask_avx512(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	size_t iterations = state.range(0);
	float *a = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *b = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *out1 = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);
	float *out2 = (float *)_mm_malloc(MAX_SIZE * sizeof(float), 64);

	init_sources(a, b, out1, out2);
	for (auto _ : state) {
		mul_zeromask_avx512(a, b, out1, out2, iterations);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(MAX_SIZE) * 2 * int64_t(sizeof(a[0])));

	_mm_free(out2);
	_mm_free(out1);
	_mm_free(b);
	_mm_free(a);
}

BENCHMARK(BM_mul_nomask_avx512)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_mul_mask_avx512)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_mul_zeromask_avx512)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
