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

#include "ternary_avx2.h"
#include "ternary_avx512.h"
#include "ternary_vpternlog.h"

static void init_sources(uint32_t *a, uint32_t *b, uint32_t *c, size_t len)
{
	for (size_t i = 0; i < len; i++) {
		a[i] = std::rand() & 1;
		b[i] = std::rand() & 1;
		c[i] = std::rand() & 1;
	}
}

static void BM_avx2_ternary(benchmark::State &state)
{
	int len = state.range(0);

	uint32_t *a = (uint32_t *)_mm_malloc(len * sizeof(*a), 32);
	uint32_t *b = (uint32_t *)_mm_malloc(len * sizeof(*a), 32);
	uint32_t *c = (uint32_t *)_mm_malloc(len * sizeof(*a), 32);
	uint32_t *out = (uint32_t *)_mm_malloc(len * sizeof(*a), 32);

	init_sources(a, b, c, len);
	memset(out, 0, sizeof(*out) * len);

	for (auto _ : state) {
		(void)ternary_avx2(out, a, b, c, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(a[0]) * 3));

	_mm_free(out);
	_mm_free(c);
	_mm_free(b);
	_mm_free(a);
}

static void BM_avx512_ternary(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint32_t *a = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);
	uint32_t *b = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);
	uint32_t *c = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);
	uint32_t *out = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);

	init_sources(a, b, c, len);
	memset(out, 0, sizeof(*out) * len);

	for (auto _ : state) {
		(void)ternary_avx512(out, a, b, c, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(a[0]) * 3));

	_mm_free(out);
	_mm_free(c);
	_mm_free(b);
	_mm_free(a);
}

static void BM_vpternlog_ternary(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint32_t *a = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);
	uint32_t *b = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);
	uint32_t *c = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);
	uint32_t *out = (uint32_t *)_mm_malloc(len * sizeof(*a), 64);

	init_sources(a, b, c, len);
	memset(out, 0, sizeof(*out) * len);

	for (auto _ : state) {
		(void)ternary_vpternlog(out, a, b, c, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(a[0]) * 3));

	_mm_free(out);
	_mm_free(c);
	_mm_free(b);
	_mm_free(a);
}

BENCHMARK(BM_avx2_ternary)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_avx512_ternary)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_vpternlog_ternary)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
