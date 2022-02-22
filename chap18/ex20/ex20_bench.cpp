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

#include "avx512_vector_dp.h"
#include "init_sparse.h"
#include "scalar_vector_dp.h"

static void BM_scalar_vector_dp(benchmark::State &state)
{
	int len = state.range(0);

	uint32_t *a_index = (uint32_t *)malloc(len * 4 * sizeof(*a_index));
	double *a_values = (double *)malloc(len * sizeof(*a_values));
	uint32_t *b_index = (uint32_t *)malloc(len * 4 * sizeof(*a_index));
	double *b_values = (double *)malloc(len * sizeof(*b_values));

	init_sparse(a_index, a_values, b_index, b_values, len);

	for (auto _ : state) {
		scalar_vector_dp(a_index, a_values, b_index, b_values, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(a_values[0]) * 2));

	free(b_values);
	free(b_index);
	free(a_values);
	free(a_index);
}

static void BM_avx512_vector_dp(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint32_t *a_index =
	    (uint32_t *)_mm_malloc(len * 4 * sizeof(*a_index), 64);
	double *a_values = (double *)_mm_malloc(len * sizeof(*a_values), 64);
	uint32_t *b_index =
	    (uint32_t *)_mm_malloc(len * 4 * sizeof(*a_index), 64);
	double *b_values = (double *)_mm_malloc(len * sizeof(*b_values), 64);

	init_sparse(a_index, a_values, b_index, b_values, len);

	for (auto _ : state) {
		avx512_vector_dp(a_index, a_values, b_index, b_values, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(a_values[0]) * 2));

	_mm_free(b_values);
	_mm_free(b_index);
	_mm_free(a_values);
	_mm_free(a_index);
}

BENCHMARK(BM_scalar_vector_dp)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx512_vector_dp)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
