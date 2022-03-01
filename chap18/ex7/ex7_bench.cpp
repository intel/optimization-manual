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

#include "blend_avx512.h"
#include "mask_avx512.h"
#include "optimisation_common.h"

static void init_sources(int len, uint32_t *a, uint32_t *b)
{
	for (int i = 0; i < len; i++) {
		a[i] = (i & 1) ? i + 1 : i;
		b[i] = i;
	}
}

static void BM_mask_avx512(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);
	uint32_t *a = (uint32_t *)_mm_malloc(len * sizeof(uint32_t), 64);
	uint32_t *b = (uint32_t *)_mm_malloc(len * sizeof(uint32_t), 64);

	init_sources(len, a, b);

	for (auto _ : state) {
		mask_avx512(a, b, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(len * 2 * sizeof(a[0])));

	_mm_free(b);
	_mm_free(a);
}

static void BM_blend_avx512(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);
	uint32_t *a = (uint32_t *)_mm_malloc(len * sizeof(uint32_t), 64);
	uint32_t *b = (uint32_t *)_mm_malloc(len * sizeof(uint32_t), 64);

	init_sources(len, a, b);

	for (auto _ : state) {
		blend_avx512(a, b, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(len * 2 * sizeof(a[0])));

	_mm_free(b);
	_mm_free(a);
}

BENCHMARK(BM_mask_avx512)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_blend_avx512)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
