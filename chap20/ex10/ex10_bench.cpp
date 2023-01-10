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

namespace
{

#ifdef COMPILER_SUPPORTS_AMX
// clang-format off

#include "amx_ref_gemm_int8.hpp"
#include "../ex1/amx_tile.hpp"
#include "gemm/amx_interleaved_gemm.hpp"
#include "../ex4/amx_int8_test_utils.hpp"
#include "optimisation_common.h"

// clang-format on

static void BM_amx_interleaved_gemm(benchmark::State &state)
{
	if (!supports_amx()) {
		state.SkipWithError("AMX not supported, skipping test");
		return;
	}

	init_sources();
	for (auto _ : state) {
		amx_ref_gemm_int8();
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(M * N * K));
}
#else
static void BM_amx_interleaved_gemm(benchmark::State &state)
{
	state.SkipWithError("Compiler does not support AMX, skipping test");
}
#endif
} // namespace

BENCHMARK(BM_amx_interleaved_gemm);
