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

#include "expand_avx2.h"
#include "expand_avx512.h"
#include "expand_scalar.h"
#include "optimisation_common.h"

static void init_sources(int32_t *in, int len)
{
	for (int i = 0; i < len; i++)
		in[i] = i & 3;
}

static void BM_scalar_expand(benchmark::State &state)
{
	int len = state.range(0);

	int32_t *in = (int32_t *)malloc(len * sizeof(*in));
	int32_t *out = (int32_t *)malloc(len * sizeof(*in));

	init_sources(in, len);
	memset(out, 0, sizeof(*out) * len);

	for (auto _ : state) {
		(void)expand_scalar(out, in, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(in[0])));

	free(out);
	free(in);
}

static void BM_AVX2_expand(benchmark::State &state)
{
	int len = state.range(0);
	int32_t *in = (int32_t *)_mm_malloc(len * sizeof(*in), 32);
	int32_t *out = (int32_t *)_mm_malloc(len * sizeof(*in), 32);

	init_sources(in, len);
	memset(out, 0, sizeof(*out) * len);

	for (auto _ : state) {
		(void)expand_avx2(out, in, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(in[0])));

	_mm_free(out);
	_mm_free(in);
}

static void BM_AVX512_expand(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);
	int32_t *in = (int32_t *)_mm_malloc(len * sizeof(*in), 64);
	int32_t *out = (int32_t *)_mm_malloc(len * sizeof(*in), 64);

	init_sources(in, len);
	memset(out, 0, sizeof(*out) * len);

	for (auto _ : state) {
		(void)expand_avx512(out, in, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(in[0])));

	_mm_free(out);
	_mm_free(in);
}

BENCHMARK(BM_scalar_expand)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_AVX2_expand)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_AVX512_expand)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
