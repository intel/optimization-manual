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

#include "avx2_vpgatherd.h"
#include "avx_vinsrt.h"
#include "scalar.h"

static void init_sources(complex_num *aos, int len)
{
	for (int i = 0; i < len; i++) {
		aos[i].real = (float)i;
		aos[i].imaginary = (float)i + 1;
	}
}

static void BM_scalar(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *aos = (complex_num *)malloc(sizeof(*aos) * len);
	float *soa_real = (float *)malloc(sizeof(float) * len);
	float *soa_imaginary = (float *)malloc(sizeof(float) * len);

	init_sources(aos, len);
	for (auto _ : state) {
		scalar(len, aos, soa_imaginary, soa_real);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));
	free(soa_imaginary);
	free(soa_real);
	free(aos);
}

static void BM_avx_vinsrt(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *aos = (complex_num *)_mm_malloc(sizeof(*aos) * len, 32);
	float *soa_real = (float *)_mm_malloc(sizeof(float) * len, 32);
	float *soa_imaginary = (float *)_mm_malloc(sizeof(float) * len, 32);

	init_sources(aos, len);
	for (auto _ : state) {
		avx_vinsrt(len, aos, soa_imaginary, soa_real);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(soa_imaginary);
	_mm_free(soa_real);
	_mm_free(aos);
}

static void BM_avx2_vpgatherd(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *aos = (complex_num *)_mm_malloc(sizeof(*aos) * len, 32);
	float *soa_real = (float *)_mm_malloc(sizeof(float) * len, 32);
	float *soa_imaginary = (float *)_mm_malloc(sizeof(float) * len, 32);

	init_sources(aos, len);
	for (auto _ : state) {
		avx2_vpgatherd(len, aos, soa_imaginary, soa_real);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(soa_imaginary);
	_mm_free(soa_real);
	_mm_free(aos);
}

BENCHMARK(BM_scalar)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx_vinsrt)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx2_vpgatherd)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
