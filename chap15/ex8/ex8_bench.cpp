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

#include "gather_scalar.h"
#include "gather_vinsert.h"
#include "gather_vinsert_vshufps.h"

static void init_sources(int32_t *in, uint32_t *indices, int len)
{
	for (int i = 0; i < len; i++) {
		in[i] = i - (len / 2);
		indices[i] = i & 1 ? i - 1 : i + 1;
	}
}

static void BM_gather_scalar(benchmark::State &state)
{
	int len = state.range(0);
	int32_t *in = (int32_t *)malloc(len * sizeof(*in));
	uint32_t *indices = (uint32_t *)malloc(len * sizeof(*indices));
	int32_t *out = (int32_t *)malloc(len * sizeof(*out));

	init_sources(in, indices, len);
	for (auto _ : state) {
		gather_scalar(in, out, indices, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*in) + sizeof(*indices)));

	free(out);
	free(indices);
	free(in);
}

static void BM_gather_vinsert(benchmark::State &state)
{
	int len = state.range(0);
	int32_t *in = (int32_t *)_mm_malloc(len * sizeof(*in), 32);
	uint32_t *indices = (uint32_t *)_mm_malloc(len * sizeof(*indices), 32);
	int32_t *out = (int32_t *)_mm_malloc(len * sizeof(*out), 32);

	init_sources(in, indices, len);
	for (auto _ : state) {
		gather_vinsert(in, out, indices, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*in) + sizeof(*indices)));

	_mm_free(out);
	_mm_free(indices);
	_mm_free(in);
}

static void BM_gather_vinsert_vshufps(benchmark::State &state)
{
	int len = state.range(0);
	int32_t *in = (int32_t *)_mm_malloc(len * sizeof(*in), 32);
	uint32_t *indices = (uint32_t *)_mm_malloc(len * sizeof(*indices), 32);
	int32_t *out = (int32_t *)_mm_malloc(len * sizeof(*out), 32);

	init_sources(in, indices, len);
	for (auto _ : state) {
		gather_vinsert_vshufps(in, out, indices, len);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*in) + sizeof(*indices)));

	_mm_free(out);
	_mm_free(indices);
	_mm_free(in);
}

BENCHMARK(BM_gather_scalar)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_gather_vinsert)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_gather_vinsert_vshufps)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
