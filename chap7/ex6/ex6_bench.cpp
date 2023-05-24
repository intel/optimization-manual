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
#include <xmmintrin.h>

#include "deswizzling_rgb_sse.h"
#include "optimisation_common.h"
#include "vertex_struct.h"

static void init_sources(Vertex_soa *in, Vertex_aos *out)
{
	for (int32_t i = 0; i < MAX_SIZE; i++) {
		in->x[i] = (float)i / 4.0f;
		in->y[i] = (float)i / 5.0f;
		in->z[i] = (float)i / 6.0f;
		in->color[i] = (float)i + 7.0f;

		out[i].x = 0.0f;
		out[i].y = 0.0f;
		out[i].z = 0.0f;
		out[i].color = 0.0f;
	}
}

static void BM_deswizzling_rgb_sse(benchmark::State &state)
{
	Vertex_aos *out = reinterpret_cast<Vertex_aos *>(
	    _mm_malloc(sizeof(*out) * MAX_SIZE, 16));
	Vertex_soa *in =
	    reinterpret_cast<Vertex_soa *>(_mm_malloc(sizeof(*in), 16));

	init_sources(in, out);

	for (auto _ : state) {
		(void)deswizzling_rgb_sse(in, out);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(MAX_SIZE) * int64_t(sizeof(*in)));

	_mm_free(out);
	_mm_free(in);
}

BENCHMARK(BM_deswizzling_rgb_sse);
BENCHMARK_MAIN();
