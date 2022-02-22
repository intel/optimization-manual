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

#include "lookup128_novbmi.h"
#include "lookup128_vbmi.h"

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static unsigned char b[128];
#else
static uint8_t b[128] __attribute__((aligned(64)));
#endif

static void init_sources(uint8_t *a, uint8_t *out, int len)
{
	for (int i = 0; i < len; i++) {
		a[i] = static_cast<uint8_t>(i % 255);
		out[i] = static_cast<uint8_t>(0);
	}
	for (size_t i = 0; i < 128; i++) {
		b[i] = static_cast<uint8_t>(127 - i);
	}
}

static void BM_lookup128_novbmi(benchmark::State &state)
{
	if (!supports_avx512_skx()) {
		state.SkipWithError("AVX-512 not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint8_t *a = (uint8_t *)_mm_malloc(len, 64);
	uint8_t *out = (uint8_t *)_mm_malloc(len, 64);

	init_sources(a, out, len);

	for (auto _ : state) {
		lookup128_novbmi(a, b, out, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len));

	_mm_free(out);
	_mm_free(a);
}

static void BM_lookup128_vbmi(benchmark::State &state)
{
	if (!supports_avx512_icl()) {
		state.SkipWithError("VBMI not supported, skipping test");
		return;
	}

	int len = state.range(0);

	uint8_t *a = (uint8_t *)_mm_malloc(len, 64);
	uint8_t *out = (uint8_t *)_mm_malloc(len, 64);

	init_sources(a, out, len);

	for (auto _ : state) {
		lookup128_vbmi(a, b, out, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len));

	_mm_free(out);
	_mm_free(a);
}

BENCHMARK(BM_lookup128_novbmi)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_lookup128_vbmi)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
