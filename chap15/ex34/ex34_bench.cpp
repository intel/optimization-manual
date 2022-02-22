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

#include "halfp.h"
#include "singlep.h"

static void init_sources(float *x, int len)
{
	for (int i = 0; i < len; i++)
		x[i] = i * 1.0f;
}

static void init_sources_half(float *x, __m128i *xh, int len)
{
	init_sources(x, len);

	for (int i = 0; i < len / 8; i++) {
		__m256 a = _mm256_loadu_ps(&x[i * 8]);
		__m128i ah = _mm256_cvtps_ph(a, _MM_FROUND_TO_NEAREST_INT);
		_mm_store_si128(&xh[i], ah);
	}
}

static void BM_singlep(benchmark::State &state)
{
	int len = state.range(0);
	float *x = (float *)_mm_malloc((len + 8) * sizeof(float), 32);
	float *y = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(x, len);

	for (auto _ : state) {
		singlep(x, y, len - 32);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*x)));

	_mm_free(y);
	_mm_free(x);
}

static void BM_halfp(benchmark::State &state)
{
	int len = state.range(0);
	float *x = (float *)_mm_malloc(len * sizeof(float), 32);
	__m128i *xh =
	    (__m128i *)_mm_malloc(((len + 1) * sizeof(__m128i)) / 8, 32);
	__m128i *yh = (__m128i *)_mm_malloc((len * sizeof(__m128i)) / 8, 32);

	init_sources_half(x, xh, len);

	for (auto _ : state) {
		halfp(xh, yh, len - 16);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*xh)));

	_mm_free(yh);
	_mm_free(xh);
	_mm_free(x);
}

BENCHMARK(BM_singlep)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18)
    ->Arg(1 << 20);
BENCHMARK(BM_halfp)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18)
    ->Arg(1 << 20);
BENCHMARK_MAIN();
