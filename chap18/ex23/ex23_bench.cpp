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

#include "decompress_novbmi.h"
#include "decompress_vbmi.h"

static void init_sources(uint8_t *a, uint8_t *out, int max_input_size, int len)
{
	for (int i = 0; i < max_input_size; i++) {
		a[i] = static_cast<uint8_t>(i % 255);
	}

	memset(out, 0, len);
}

static void BM_decompress_novbmi(benchmark::State &state)
{
	int len = state.range(0);
	int input_size = (len / 40) * 40;
	int max_input_size = input_size + 24;

	uint8_t *a = (uint8_t *)malloc(max_input_size);
	uint8_t *out = (uint8_t *)malloc(len);

	init_sources(a, out, max_input_size, len);

	for (auto _ : state) {
		decompress_novbmi(len, out, a);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(input_size));

	free(out);
	free(a);
}

static void BM_decompress_vbmi(benchmark::State &state)
{
	if (!supports_avx512_icl()) {
		state.SkipWithError("VBMI not supported, skipping test");
		return;
	}

	int len = state.range(0);
	int input_size = (len / 40) * 40;
	int max_input_size = input_size + 24;

	uint8_t *a = (uint8_t *)_mm_malloc(max_input_size, 64);
	uint8_t *out = (uint8_t *)_mm_malloc(len, 64);

	init_sources(a, out, max_input_size, len);

	for (auto _ : state) {
		decompress_vbmi(out, a, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(input_size));

	_mm_free(out);
	_mm_free(a);
}

BENCHMARK(BM_decompress_novbmi)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_decompress_vbmi)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
