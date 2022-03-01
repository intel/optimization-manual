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

#include "mul_cpx_mem.h"
#include "mul_cpx_reg.h"

static void init_sources(complex_num *x, complex_num *y, int len)
{
	for (int i = 0; i < len; i++) {
		x[i].real = (float)i;
		x[i].imaginary = (float)i + 1;
		y[i].real = x[i].real * 2;
		y[i].imaginary = x[i].imaginary * 2;
	}
}

static void BM_mul_cpx_reg(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *x =
	    (complex_num *)_mm_malloc(len * sizeof(complex_num), 32);
	complex_num *y =
	    (complex_num *)_mm_malloc(len * sizeof(complex_num), 32);
	complex_num *z =
	    (complex_num *)_mm_malloc(len * sizeof(complex_num), 32);

	init_sources(x, y, len);

	for (auto _ : state) {
		mul_cpx_reg(x, y, z, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*x) * 2));

	_mm_free(z);
	_mm_free(y);
	_mm_free(x);
}

static void BM_mul_cpx_mem(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *x =
	    (complex_num *)_mm_malloc(len * sizeof(complex_num), 32);
	complex_num *y =
	    (complex_num *)_mm_malloc(len * sizeof(complex_num), 32);
	complex_num *z =
	    (complex_num *)_mm_malloc(len * sizeof(complex_num), 32);

	init_sources(x, y, len);

	for (auto _ : state) {
		mul_cpx_mem(x, y, z, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*x) * 2));

	_mm_free(z);
	_mm_free(y);
	_mm_free(x);
}

BENCHMARK(BM_mul_cpx_reg)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_mul_cpx_mem)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
