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

#include "s2s_vpermi2d.h"
#include "s2s_vscatterdps.h"

static void init_sources(complex_num *aos, float *soa_real,
			 float *soa_imaginary, int len)
{
	for (int i = 0; i < len; i++) {
		soa_real[i] = (float)i;
		soa_imaginary[i] = (float)i + 1;
		aos[i].real = 0.0;
		aos[i].imaginary = 0.0;
	}
}

static void BM_s2s_vscatterdps(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	complex_num *aos =
	    reinterpret_cast<complex_num *>(_mm_malloc(sizeof(*aos) * len, 64));
	float *soa_real =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*soa_real) * len, 64));
	float *soa_imaginary = reinterpret_cast<float *>(
	    _mm_malloc(sizeof(*soa_imaginary) * len, 64));

	init_sources(aos, soa_real, soa_imaginary, len);

	for (auto _ : state) {
		s2s_vscatterdps(len, soa_imaginary, soa_real, aos);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(soa_imaginary);
	_mm_free(soa_real);
	_mm_free(aos);
}

static void BM_s2s_vpermi2d(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = static_cast<uint64_t>(state.range(0));
	complex_num *aos =
	    reinterpret_cast<complex_num *>(_mm_malloc(sizeof(*aos) * len, 64));
	float *soa_real =
	    reinterpret_cast<float *>(_mm_malloc(sizeof(*soa_real) * len, 64));
	float *soa_imaginary = reinterpret_cast<float *>(
	    _mm_malloc(sizeof(*soa_imaginary) * len, 64));

	init_sources(aos, soa_real, soa_imaginary, len);

	for (auto _ : state) {
		s2s_vpermi2d(len, soa_imaginary, soa_real, aos);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(*aos)));

	_mm_free(soa_imaginary);
	_mm_free(soa_real);
	_mm_free(aos);
}

BENCHMARK(BM_s2s_vscatterdps)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_s2s_vpermi2d)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
