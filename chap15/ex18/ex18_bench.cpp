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

#include "three_tap_mixed_avx.h"

static void init_sources(float *a, float *coeff, int len)
{
	coeff[0] = 1;
	coeff[1] = 3;
	coeff[2] = 7;

	for (int i = 0; i < len; i++)
		a[i] = (float)i;
}

static void BM_three_tap_mixed_avx(benchmark::State &state)
{
	int len = state.range(0);
	float coeff[3];
	float *a = (float *)_mm_malloc(len * sizeof(float), 32);
	float *out = (float *)_mm_malloc(len * sizeof(float), 32);

	init_sources(a, coeff, len);

	for (auto _ : state) {
		three_tap_mixed_avx(a, coeff, out, len - 2);
	}

	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(float) + 1));

	_mm_free(out);
	_mm_free(a);
}

BENCHMARK(BM_three_tap_mixed_avx)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
