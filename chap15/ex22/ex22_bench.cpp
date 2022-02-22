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

#include "divps_sse.h"
#include "vdivps_avx.h"

static void init_sources(float *x, float *y, int len)
{
	for (int i = 0; i < len; i++) {
		x[i] = i * 1.0f;
		y[i] = (len - i) * 1.0f;
	}
}

static void BM_divps_sse(benchmark::State &state)
{
	int len = state.range(0);
	float *x = (float *)_mm_malloc(len * sizeof(float), 16);
	float *y = (float *)_mm_malloc(len * sizeof(float), 16);
	float *z = (float *)_mm_malloc(len * sizeof(float), 16);

	init_sources(x, y, len);

	for (auto _ : state) {
		divps_sse(x, y, z, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*x) * 2));

	_mm_free(z);
	_mm_free(y);
	_mm_free(x);
}

static void BM_vdivps_avx(benchmark::State &state)
{
	int len = state.range(0);
	float *x = (float *)_mm_malloc(len * sizeof(float), 32);
	float *y = (float *)_mm_malloc(len * sizeof(float), 32);
	float *z = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(x, y, len);

	for (auto _ : state) {
		vdivps_avx(x, y, z, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*x) * 2));

	_mm_free(z);
	_mm_free(y);
	_mm_free(x);
}

BENCHMARK(BM_divps_sse)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_vdivps_avx)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
