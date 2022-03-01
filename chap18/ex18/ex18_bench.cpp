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

#include "optimisation_common.h"

#include "qword_avx2.h"
#include "qword_avx512.h"

static void init_sources(int64_t *input_a, int64_t *input_b, int len)
{
	for (int i = 0; i < len; i++) {
		input_a[i] = rand() - (RAND_MAX / 2);
		input_b[i] = rand() - (RAND_MAX / 2);
	}
}

static void BM_qword_avx2_instrinsics(benchmark::State &state)
{
	int len = state.range(0);

	int64_t *input_a = (int64_t *)_mm_malloc(len * sizeof(*input_a), 32);
	int64_t *input_b = (int64_t *)_mm_malloc(len * sizeof(*input_b), 32);
	int64_t *output = (int64_t *)_mm_malloc(len * sizeof(*output), 32);

	init_sources(input_a, input_b, len);

	for (auto _ : state) {
		qword_avx2_intrinsics(input_a, input_b, output, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(input_a[0]) * 2));

	_mm_free(output);
	_mm_free(input_b);
	_mm_free(input_a);
}

static void BM_qword_avx2_ass(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	int64_t *input_a = (int64_t *)_mm_malloc(len * sizeof(*input_a), 32);
	int64_t *input_b = (int64_t *)_mm_malloc(len * sizeof(*input_b), 32);
	int64_t *output = (int64_t *)_mm_malloc(len * sizeof(*output), 32);

	init_sources(input_a, input_b, len);

	for (auto _ : state) {
		qword_avx2_ass(input_a, input_b, output, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(input_a[0]) * 2));

	_mm_free(output);
	_mm_free(input_b);
	_mm_free(input_a);
}

static void BM_qword_avx512_instrinsics(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	int64_t *input_a = (int64_t *)_mm_malloc(len * sizeof(*input_a), 64);
	int64_t *input_b = (int64_t *)_mm_malloc(len * sizeof(*input_b), 64);
	int64_t *output = (int64_t *)_mm_malloc(len * sizeof(*output), 64);

	init_sources(input_a, input_b, len);

	for (auto _ : state) {
		qword_avx512_intrinsics(input_a, input_b, output, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(input_a[0]) * 2));

	_mm_free(output);
	_mm_free(input_b);
	_mm_free(input_a);
}

static void BM_qword_avx512_ass(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	int64_t *input_a = (int64_t *)_mm_malloc(len * sizeof(*input_a), 64);
	int64_t *input_b = (int64_t *)_mm_malloc(len * sizeof(*input_b), 64);
	int64_t *output = (int64_t *)_mm_malloc(len * sizeof(*output), 64);

	init_sources(input_a, input_b, len);

	for (auto _ : state) {
		qword_avx512_ass(input_a, input_b, output, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(input_a[0]) * 2));

	_mm_free(output);
	_mm_free(input_b);
	_mm_free(input_a);
}

BENCHMARK(BM_qword_avx2_instrinsics)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_qword_avx2_ass)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_qword_avx512_instrinsics)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_qword_avx512_ass)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
