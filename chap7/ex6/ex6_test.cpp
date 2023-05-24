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

#include <xmmintrin.h>

#include "gtest/gtest.h"

#include "deswizzling_rgb_sse.h"
#include "optimisation_common.h"
#include "vertex_struct.h"

#ifdef _MSC_VER
#else
#endif

alignas(16) static Vertex_soa in;
alignas(16) static Vertex_aos out[MAX_SIZE];

static void init_sources()
{
	for (int32_t i = 0; i < MAX_SIZE; i++) {
		in.x[i] = (float)i / 4.0f;
		in.y[i] = (float)i / 5.0f;
		in.z[i] = (float)i / 6.0f;
		in.color[i] = (float)i + 7.0f;

		out[i].x = 0.0f;
		out[i].y = 0.0f;
		out[i].z = 0.0f;
		out[i].color = 0.0f;
	}
}

TEST(unpck_sse_6, deswizzling_rgb_sse)
{
	init_sources();
	ASSERT_EQ(deswizzling_rgb_sse_check(&in, out), true);

	for (int i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(out[i].x, in.x[i]);
		ASSERT_FLOAT_EQ(out[i].y, in.y[i]);
		ASSERT_FLOAT_EQ(out[i].z, in.z[i]);
		ASSERT_FLOAT_EQ(out[i].color, in.color[i]);
	}
}
