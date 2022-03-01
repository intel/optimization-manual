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

#include "complex_conv_avx_stride.h"
#include "complex_conv_sse.h"

static void init_sources(complex_num *aos, int len)
{
	for (int i = 0; i < len; i++) {
		aos[i].real = (float)i;
		aos[i].imaginary = (float)i + 1;
	}
}

static void BM_complex_conv_sse(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *aos = (complex_num *)_mm_malloc(len * sizeof(*aos), 16);
	float *real = (float *)_mm_malloc(len * sizeof(float), 16);
	float *imag = (float *)_mm_malloc(len * sizeof(float), 16);

	init_sources(aos, len);

	for (auto _ : state) {
		complex_conv_sse(aos, real, imag, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(imag);
	_mm_free(real);
	_mm_free(aos);
}

static void BM_complex_conv_avx_stride(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *aos = (complex_num *)_mm_malloc(len * sizeof(*aos), 32);
	float *real = (float *)_mm_malloc(len * sizeof(float), 32);
	float *imag = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(aos, len);

	for (auto _ : state) {
		complex_conv_avx_stride(aos, real, imag, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(imag);
	_mm_free(real);
	_mm_free(aos);
}

BENCHMARK(BM_complex_conv_sse)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_complex_conv_avx_stride)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
