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

#include "saxpy16.h"
#include "saxpy32.h"

static void init_sources(float *src, float *src2, int len)
{
	for (int i = 0; i < len; i++) {
		src[i] = 2.0f * i;
		src2[i] = 3.0f * i;
	}
}

static void BM_saxpy32(benchmark::State &state)
{
	int len = state.range(0);
	float *src_mem = (float *)_mm_malloc((len + 1) * sizeof(float), 32);
	float *src = &src_mem[1];
	float *src2_mem = (float *)_mm_malloc((len + 1) * sizeof(float), 32);
	float *src2 = &src2_mem[1];
	float *dest = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(src, src2, len);

	for (auto _ : state) {
		saxpy32(src, src2, len * sizeof(float), dest, 10.0);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(float) * 2));

	_mm_free(dest);
	_mm_free(src2_mem);
	_mm_free(src_mem);
}

static void BM_saxpy16(benchmark::State &state)
{
	int len = state.range(0);
	float *src_mem = (float *)_mm_malloc((len + 1) * sizeof(float), 32);
	float *src = &src_mem[1];
	float *src2_mem = (float *)_mm_malloc((len + 1) * sizeof(float), 32);
	float *src2 = &src2_mem[1];
	float *dest = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(src, src2, len);

	for (auto _ : state) {
		saxpy16(src, src2, len * sizeof(float), dest, 10.0);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(float) * 2));

	_mm_free(dest);
	_mm_free(src2_mem);
	_mm_free(src_mem);
}

BENCHMARK(BM_saxpy32)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_saxpy16)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
