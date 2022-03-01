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

#include "saxpy_512.h"

static void init_sources(float *src, float *src2, int len)
{
	for (int32_t i = 0; i < len; i++) {
		src[i] = 2.0f * i;
		src2[i] = 3.0f * i;
	}
}

static void BM_saxpy512_aligned(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	float *src =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*src) * len, 64));
	float *src2 =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*src2) * len, 64));
	float *dest =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*dest) * len, 64));

	init_sources(src, src2, len);

	for (auto _ : state) {
		saxpy_512(src, src2, len, dest, 10.0);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*src)) * int64_t(2));

	_mm_free(dest);
	_mm_free(src2);
	_mm_free(src);
}

static void BM_saxpy512_unaligned_dest(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	float *src =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*src) * len, 64));
	float *src2 =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*src2) * len, 64));
	float *dest = reinterpret_cast<float *>(
	    _mm_malloc(sizeof(*dest) * (len + 1), 64));

	init_sources(src, src2, len);

	for (auto _ : state) {
		saxpy_512(src, src2, len, &dest[1], 10.0);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*src)) * int64_t(2));

	_mm_free(dest);
	_mm_free(src2);
	_mm_free(src);
}

static void BM_saxpy512_unaligned(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	float *src =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*src) * (len + 1), 64));
	float *src2 = reinterpret_cast<float *>(
	    _mm_malloc(sizeof(*src2) * (len + 1), 64));
	float *dest = reinterpret_cast<float *>(
	    _mm_malloc(sizeof(*dest) * (len + 1), 64));

	init_sources(&src[1], &src2[1], len);

	for (auto _ : state) {
		saxpy_512(&src[1], &src2[1], len, &dest[1], 10.0);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*src)) * int64_t(2));

	_mm_free(dest);
	_mm_free(src2);
	_mm_free(src);
}

static void BM_saxpy512_unaligned_src(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	float *src =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*src) * len, 64));
	float *src2 =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*src2) * len, 64));
	float *dest = reinterpret_cast<float *>(
	    _mm_malloc(sizeof(*dest) * (len + 1), 64));

	init_sources(&src[1], src2, len);

	for (auto _ : state) {
		saxpy_512(&src[1], src2, len, dest, 10.0);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*src)) * int64_t(2));

	_mm_free(dest);
	_mm_free(src2);
	_mm_free(src);
}

BENCHMARK(BM_saxpy512_aligned)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 13)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_saxpy512_unaligned_dest)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 13)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_saxpy512_unaligned)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 13)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_saxpy512_unaligned_src)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 13)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
