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

#include <stdint.h>

#include <benchmark/benchmark.h>
#include <xmmintrin.h>

#include "avx2_gatherpd.h"
#include "avx_vinsert.h"

static void init_sources(complex_num *aos, uint32_t *indices, int len)
{
	for (int i = 0; i < len; i++) {
		indices[i] = ((uint32_t)len - (i + 1));
		aos[i].real = (double)i;
		aos[i].imaginary = (double)i + 1;
	}
}

static void BM_avx2_gatherpd(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *aos = (complex_num *)_mm_malloc(sizeof(*aos) * len, 32);
	double *soa_real = (double *)_mm_malloc(sizeof(double) * len, 32);
	double *soa_imaginary = (double *)_mm_malloc(sizeof(double) * len, 32);
	uint32_t *indices = (uint32_t *)_mm_malloc(sizeof(uint32_t) * len, 32);

	init_sources(aos, indices, len);
	for (auto _ : state) {
		avx2_gatherpd(len, indices, soa_imaginary, soa_real, aos);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(indices);
	_mm_free(soa_imaginary);
	_mm_free(soa_real);
	_mm_free(aos);
}

static void BM_avx_vinsert(benchmark::State &state)
{
	int len = state.range(0);
	complex_num *aos = (complex_num *)_mm_malloc(sizeof(*aos) * len, 32);
	double *soa_real = (double *)_mm_malloc(sizeof(double) * len, 32);
	double *soa_imaginary = (double *)_mm_malloc(sizeof(double) * len, 32);
	uint32_t *indices = (uint32_t *)_mm_malloc(sizeof(uint32_t) * len, 32);

	init_sources(aos, indices, len);
	for (auto _ : state) {
		avx_vinsert(len, indices, soa_imaginary, soa_real, aos);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(indices);
	_mm_free(soa_imaginary);
	_mm_free(soa_real);
	_mm_free(aos);
}

BENCHMARK(BM_avx2_gatherpd)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx_vinsert)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
