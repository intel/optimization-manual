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

#include "poly_avx_128.h"
#include "poly_avx_256.h"
#include "poly_sse.h"

static void init_sources(float *in, float *out, int len)
{
	for (int i = 0; i < len; i++) {
		in[i] = (float)i / 4.0f;
		out[i] = 0.0f;
	}
}

static void BM_poly_sse(benchmark::State &state)
{
	int len = state.range(0);
	float *in = (float *)_mm_malloc(len * sizeof(float), 16);
	float *out = (float *)_mm_malloc(len * sizeof(float), 16);

	init_sources(in, out, len);

	for (auto _ : state) {
		poly_sse(in, out, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(in[0])));

	_mm_free(out);
	_mm_free(in);
}

static void BM_poly_avx_128(benchmark::State &state)
{
	int len = state.range(0);
	float *in = (float *)_mm_malloc(len * sizeof(float), 32);
	float *out = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(in, out, len);

	for (auto _ : state) {
		poly_avx_128(in, out, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(in[0])));

	_mm_free(out);
	_mm_free(in);
}

static void BM_poly_avx_256(benchmark::State &state)
{
	int len = state.range(0);
	float *in = (float *)_mm_malloc(len * sizeof(float), 32);
	float *out = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(in, out, len);

	for (auto _ : state) {
		poly_avx_256(in, out, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(in[0])));

	_mm_free(out);
	_mm_free(in);
}

BENCHMARK(BM_poly_sse)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_poly_avx_128)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_poly_avx_256)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
