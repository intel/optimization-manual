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

#include "cond_scalar.h"
#include "cond_vmaskmov.h"

static void init_sources(float *a, float *c, float *d, float *e, int len)
{
	for (int i = 0; i < len; i++) {
		a[i] = (float)(i & 1);
		e[i] = (float)i;
		c[i] = (float)i * 2;
		d[i] = (float)i * 3;
	}
}

static void BM_cond_scalar(benchmark::State &state)
{
	int len = state.range(0);
	float *a = (float *)_mm_malloc(len * sizeof(float), 32);
	float *b = (float *)_mm_malloc(len * sizeof(float), 32);
	float *c = (float *)_mm_malloc(len * sizeof(float), 32);
	float *d = (float *)_mm_malloc(len * sizeof(float), 32);
	float *e = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(a, c, d, e, len);

	for (auto _ : state) {
		cond_scalar(a, b, d, c, e, len);
	}
	_mm_free(a);
	_mm_free(b);
	_mm_free(c);
	_mm_free(d);
	_mm_free(e);
}

static void BM_cond_vmaskmov(benchmark::State &state)
{
	int len = state.range(0);
	float *a = (float *)_mm_malloc(len * sizeof(float), 32);
	float *b = (float *)_mm_malloc(len * sizeof(float), 32);
	float *c = (float *)_mm_malloc(len * sizeof(float), 32);
	float *d = (float *)_mm_malloc(len * sizeof(float), 32);
	float *e = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(a, c, d, e, len);

	for (auto _ : state) {
		cond_vmaskmov(a, b, d, c, e, len);
	}
	_mm_free(a);
	_mm_free(b);
	_mm_free(c);
	_mm_free(d);
	_mm_free(e);
}

BENCHMARK(BM_cond_scalar)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_cond_vmaskmov)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
