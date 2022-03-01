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

#include "adj_load_masked_broadcast.h"
#include "adj_vpgatherpd.h"
#include "elem_struct.h"

static void init_sources(elem_struct_t *in, int32_t *indices, int len)
{
	for (int32_t i = 0; i < len; i++) {
		for (size_t j = 0; j < 4; j++)
			in[i].var[j] = ((double)rand()) / RAND_MAX;
		indices[i] = i;
	}

	for (int i = 0; i < len; i++) {
		size_t a = rand() % len;
		size_t b = rand() % len;
		int32_t tmp = indices[a];
		indices[a] = indices[b];
		indices[b] = tmp;
	}
}

static void BM_adj_vpgatherpd(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	elem_struct_t *in =
	    reinterpret_cast<elem_struct_t *>(malloc(sizeof(*in) * len));
	double *out =
	    reinterpret_cast<double *>(_mm_malloc(4 * sizeof(*out) * len, 64));
	int32_t *indices =
	    reinterpret_cast<int32_t *>(_mm_malloc(sizeof(*indices) * len, 64));

	init_sources(in, indices, len);

	for (auto _ : state) {
		adj_vpgatherpd(len, indices, in, out);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*in)));

	_mm_free(indices);
	_mm_free(out);
	free(in);
}

static void BM_adj_load_masked_broadcast(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	elem_struct_t *in =
	    reinterpret_cast<elem_struct_t *>(malloc(sizeof(*in) * len));
	double *out =
	    reinterpret_cast<double *>(_mm_malloc(4 * sizeof(*out) * len, 64));
	int32_t *indices =
	    reinterpret_cast<int32_t *>(_mm_malloc(sizeof(*indices) * len, 64));

	init_sources(in, indices, len);

	for (auto _ : state) {
		adj_load_masked_broadcast(len, indices, in, out);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*in)));

	_mm_free(indices);
	_mm_free(out);
	free(in);
}

BENCHMARK(BM_adj_vpgatherpd)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_adj_load_masked_broadcast)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
