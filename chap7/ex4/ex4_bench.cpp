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
#include <string.h>
#include <xmmintrin.h>

#include "optimisation_common.h"
#include "swizzling_unpck_sse.h"
#include "vertex_struct.h"

static void init_sources(Vertex_aos *in, Vertex_soa *out)
{
	for (int32_t i = 0; i < MAX_SIZE; i++) {
		in[i].x = (float)i / 4.0f;
		in[i].y = (float)i / 5.0f;
		in[i].z = (float)i / 6.0f;
		in[i].color = (float)i + 7.0f;

		out->x[i] = 0.0f;
		out->y[i] = 0.0f;
		out->z[i] = 0.0f;
		out->color[i] = 0.0f;
	}
}

static void BM_swizzling_unpck_sse(benchmark::State &state)
{
	Vertex_aos *in = reinterpret_cast<Vertex_aos *>(
	    _mm_malloc(sizeof(*in) * MAX_SIZE, 32));
	Vertex_soa *out =
	    reinterpret_cast<Vertex_soa *>(_mm_malloc(sizeof(*out), 32));

	init_sources(in, out);

	for (auto _ : state) {
		(void)swizzling_unpck_sse(in, out);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) *
				int64_t(MAX_SIZE) * int64_t(sizeof(*in)));

	_mm_free(out);
	_mm_free(in);
}

BENCHMARK(BM_swizzling_unpck_sse);
BENCHMARK_MAIN();
