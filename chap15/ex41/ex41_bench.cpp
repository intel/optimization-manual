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

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

#include "i64toa_avx2.h"

#include <benchmark/benchmark.h>

static void BM_sprintf_itoa(benchmark::State &state)
{
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(32)) char buf[128];
#else
	char buf[128] __attribute__((aligned(32)));
#endif
	int64_t num;

	for (auto _ : state) {
		num = 1;
		for (size_t i = 0; i < 62; i++) {
			sprintf(buf, "%" PRId64, num);
			num *= 2;
		}
	}

	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(sizeof(int64_t) * 62));
}

static void BM_i64toa_avx2i(benchmark::State &state)
{
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(32)) char buf[128];
#else
	char buf[128] __attribute__((aligned(32)));
#endif
	int64_t num;

	for (auto _ : state) {
		num = 1;
		for (size_t i = 0; i < 62; i++) {
			i64toa_avx2i(num, buf);
			num *= 2;
		}
	}

	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(sizeof(int64_t) * 62));
}

BENCHMARK(BM_sprintf_itoa);
BENCHMARK(BM_i64toa_avx2i);
BENCHMARK_MAIN();
