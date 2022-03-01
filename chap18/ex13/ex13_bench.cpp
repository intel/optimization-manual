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
#include <string.h>
#include <xmmintrin.h>

#include "optimisation_common.h"

#include "transpose_avx2.h"
#include "transpose_avx512.h"
#include "transpose_scalar.h"

const size_t MATRIX_W = 8;
const size_t MATRIX_H = 8;
const size_t MATRIX_COUNT = 50;
const size_t TOTAL_ELEMENTS = MATRIX_W * MATRIX_H * MATRIX_COUNT;

static void init_sources(uint16_t *in)
{
	uint16_t counter = 0;

	for (size_t i = 0; i < MATRIX_COUNT; i++)
		for (size_t j = 0; j < MATRIX_H; j++)
			for (size_t k = 0; k < MATRIX_W; k++) {
				in[counter] = counter;
				counter++;
			}
}

static void BM_scalar_transpose(benchmark::State &state)
{
	int len = state.range(0);

	uint16_t *in = (uint16_t *)malloc(TOTAL_ELEMENTS * sizeof(*in));
	uint16_t *out = (uint16_t *)malloc(TOTAL_ELEMENTS * sizeof(*out));

	init_sources(in);
	memset(out, 0, TOTAL_ELEMENTS * sizeof(*out));

	for (auto _ : state) {
		for (int i = 0; i < len; i++)
			(void)transpose_scalar(out, in);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(TOTAL_ELEMENTS * sizeof(in[0])));

	free(out);
	free(in);
}

static void BM_avx2_transpose(benchmark::State &state)
{
	int len = state.range(0);

	uint16_t *in = (uint16_t *)_mm_malloc(TOTAL_ELEMENTS * sizeof(*in), 32);
	uint16_t *out =
	    (uint16_t *)_mm_malloc(TOTAL_ELEMENTS * sizeof(*out), 32);

	init_sources(in);
	memset(out, 0, TOTAL_ELEMENTS * sizeof(*out));

	for (auto _ : state) {
		for (int i = 0; i < len; i++)
			(void)transpose_avx2(out, in);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(TOTAL_ELEMENTS * sizeof(in[0])));

	_mm_free(out);
	_mm_free(in);
}

static void BM_avx512_transpose(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint16_t *in = (uint16_t *)_mm_malloc(TOTAL_ELEMENTS * sizeof(*in), 64);
	uint16_t *out =
	    (uint16_t *)_mm_malloc(TOTAL_ELEMENTS * sizeof(*out), 64);

	init_sources(in);
	memset(out, 0, TOTAL_ELEMENTS * sizeof(*out));

	for (auto _ : state) {
		for (int i = 0; i < len; i++)
			(void)transpose_avx512(out, in);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(TOTAL_ELEMENTS * sizeof(in[0])));

	_mm_free(out);
	_mm_free(in);
}

BENCHMARK(BM_scalar_transpose)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx2_transpose)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx512_transpose)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
