/*
 * Copyright (C) 2023 by Intel Corporation
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

#include "direct_conv.h"
#include "optimisation_common.h"

static void BM_direct_conv_opt_scalar(benchmark::State &state)
{
    direct_conv_dims_t dims = {34, 34, 32, 32, 3, 3, 1, 1, 2, 2};

    if (!init_data(&dims)) {
        state.SkipWithError("Failed to allocate memory");
        return;
    }

    for (auto _ : state) {
        memset(c_buffer_vnni, 0, C_SIZE(&dims));

        direct_conv_opt_scalar(&dims, a_buffer_vnni, b_buffer_vnni,
                               c_buffer_vnni);
    }

    state.SetBytesProcessed(int64_t(state.iterations()) * A_SIZE(&dims) *
                            B_SIZE(&dims));

    free_data();
}

static void BM_direct_conv_opt(benchmark::State &state)
{
    if (!supports_avx512_clx()) {
        state.SkipWithError("VNNI not supported, skipping test");
        return;
    }

    direct_conv_dims_t dims = {34, 34, 32, 32, 3, 3, 1, 1, 2, 2};

    if (!init_data(&dims)) {
        state.SkipWithError("Failed to allocate memory");
        return;
    }

    for (auto _ : state) {
        memset(c_buffer_vnni, 0, C_SIZE(&dims));

        direct_conv_opt(&dims, a_buffer_vnni, b_buffer_vnni, c_buffer_vnni);
    }

    state.SetBytesProcessed(int64_t(state.iterations()) * A_SIZE(&dims) *
                            B_SIZE(&dims));

    free_data();
}

static void BM_direct_conv_ref(benchmark::State &state)
{
    direct_conv_dims_t dims = {34, 34, 32, 32, 3, 3, 1, 1, 2, 2};

    if (!init_data(&dims)) {
        state.SkipWithError("Failed to allocate memory");
        return;
    }

    for (auto _ : state) {
        memset(c_buffer_vnni, 0, C_SIZE(&dims));

        direct_conv_ref(&dims, a_buffer_vnni, b_buffer_vnni, c_buffer_vnni);
    }

    state.SetBytesProcessed(int64_t(state.iterations()) * A_SIZE(&dims) *
                            B_SIZE(&dims));

    free_data();
}

BENCHMARK(BM_direct_conv_ref);
BENCHMARK(BM_direct_conv_opt_scalar);
BENCHMARK(BM_direct_conv_opt);
BENCHMARK_MAIN();
