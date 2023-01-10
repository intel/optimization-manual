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

#include <xmmintrin.h>

#include "gtest/gtest.h"

#include "optimisation_common.h"
#include "swizzling_unpck_sse.h"
#include "vertex_struct.h"

#ifdef _MSC_VER
__declspec(align(32)) static Vertex_aos in[MAX_SIZE];
__declspec(align(32)) static Vertex_soa out;
#else
static Vertex_aos in[MAX_SIZE] __attribute__((aligned(32)));
static Vertex_soa out __attribute__((aligned(32)));
#endif

static void init_sources()
{
	for (int32_t i = 0; i < MAX_SIZE; i++) {
		in[i].x = (float)i / 4.0f;
		in[i].y = (float)i / 5.0f;
		in[i].z = (float)i / 6.0f;
		in[i].color = (float)i + 7.0f;

		out.x[i] = 0.0f;
		out.y[i] = 0.0f;
		out.z[i] = 0.0f;
		out.color[i] = 0.0f;
	}
}

TEST(unpck_sse_3, swizzling_unpck_sse)
{
	init_sources();
	ASSERT_EQ(swizzling_unpck_sse_check(in, &out), true);

	for (int i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(in[i].x, out.x[i]);
		ASSERT_FLOAT_EQ(in[i].y, out.y[i]);
		ASSERT_FLOAT_EQ(in[i].z, out.z[i]);
		ASSERT_FLOAT_EQ(in[i].color, out.color[i]);
	}
}
