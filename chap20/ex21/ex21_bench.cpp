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

#include "embedding.h"

/*
 * This benchmark uses lots of memory, 16GB.  If you have less memory
 * available on your system then adjust the following constant.
 */

#define NUM_64B_BLOCKS (((1024L * 1024L * 1024L) / 64L) * 16)
#define NUM_INDICES (16 * 1024)

static void BM_prefetched_embedding(benchmark::State &state)
{
	float *e = NULL;
	uint32_t *a = NULL;
	float *c = NULL;
	size_t lookahead = state.range(0);

	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	srand(0);

	e = static_cast<float *>(
	    _mm_malloc(NUM_64B_BLOCKS * CACHE_LINE_SIZE, CACHE_LINE_SIZE));
	if (!e)
		goto cleanup;

	a = static_cast<uint32_t *>(
	    malloc(sizeof(*a) * (NUM_INDICES + lookahead)));
	if (!a)
		goto cleanup;

	c = static_cast<float *>(
	    _mm_malloc(NUM_INDICES * CACHE_LINE_SIZE, CACHE_LINE_SIZE));
	if (!e)
		goto cleanup;

	memset(e, 0, NUM_64B_BLOCKS * CACHE_LINE_SIZE);

	for (size_t i = 0; i < NUM_INDICES; i++)
		a[i] = rand() % NUM_64B_BLOCKS;

	for (size_t i = NUM_INDICES; i < NUM_INDICES + lookahead; i++)
		a[i] = 0;

	for (auto _ : state) {
		prefetched_embedding(a, e, c, NUM_INDICES, 2.0, 0.3, lookahead);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(NUM_INDICES) * CACHE_LINE_SIZE);

cleanup:
	_mm_free(c);
	free(a);
	_mm_free(e);
}

static void BM_noprefetched_embedding(benchmark::State &state)
{
	float *e = NULL;
	uint32_t *a = NULL;
	float *c = NULL;

	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	srand(0);

	e = static_cast<float *>(
	    _mm_malloc(NUM_64B_BLOCKS * CACHE_LINE_SIZE, CACHE_LINE_SIZE));
	if (!e)
		goto cleanup;

	a = static_cast<uint32_t *>(malloc(sizeof(*a) * NUM_INDICES));
	if (!a)
		goto cleanup;

	c = static_cast<float *>(
	    _mm_malloc(NUM_INDICES * CACHE_LINE_SIZE, CACHE_LINE_SIZE));
	if (!e)
		goto cleanup;

	memset(e, 0, NUM_64B_BLOCKS * CACHE_LINE_SIZE);

	for (size_t i = 0; i < NUM_INDICES; i++)
		a[i] = rand() % NUM_64B_BLOCKS;

	for (auto _ : state) {
		noprefetched_embedding(a, e, c, NUM_INDICES, 2.0, 0.3);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(NUM_INDICES) * CACHE_LINE_SIZE);

cleanup:
	_mm_free(c);
	free(a);
	_mm_free(e);
}

BENCHMARK(BM_noprefetched_embedding);
BENCHMARK(BM_prefetched_embedding)
    ->Arg(1)
    ->Arg(3)
    ->Arg(5)
    ->Arg(10)
    ->Arg(15)
    ->Arg(20)
    ->Arg(25)
    ->Arg(30)
    ->Arg(40)
    ->Arg(50);

BENCHMARK_MAIN();
