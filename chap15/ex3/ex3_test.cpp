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

#include <xmmintrin.h>

#include "gtest/gtest.h"

#include "poly_avx_128.h"
#include "poly_avx_256.h"
#include "poly_sse.h"

const int32_t MAX_SIZE = 1024;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float in[MAX_SIZE];
__declspec(align(32)) static float out[MAX_SIZE];
#else
static float in[MAX_SIZE] __attribute__((aligned(32)));
static float out[MAX_SIZE] __attribute__((aligned(32)));
#endif

static void init_sources()
{
	for (int i = 0; i < MAX_SIZE; i++) {
		in[i] = (float)i / 4.0f;
		out[i] = 0.0f;
	}
}

TEST(avx_3, poly_sse)
{
	init_sources();
	ASSERT_EQ(poly_sse_check(in, out, MAX_SIZE), true);
	for (int i = 0; i < MAX_SIZE; i++) {
		float sq = in[i] * in[i];
		float cb = sq * in[i];
		ASSERT_FLOAT_EQ(sq + cb + in[i], out[i]);
	}

	ASSERT_EQ(poly_sse_check(in, out, 0), false);
	ASSERT_EQ(poly_sse_check(in, out, 3), false);
	ASSERT_EQ(poly_sse_check(NULL, out, MAX_SIZE), false);
	ASSERT_EQ(poly_sse_check(in, NULL, MAX_SIZE), false);
}

TEST(avx_3, poly_avx_128)
{
	init_sources();
	ASSERT_EQ(poly_avx_128_check(in, out, MAX_SIZE), true);
	for (int i = 0; i < MAX_SIZE; i++) {
		float sq = in[i] * in[i];
		float cb = sq * in[i];
		ASSERT_FLOAT_EQ(sq + cb + in[i], out[i]);
	}
	ASSERT_EQ(poly_avx_128_check(in, out, 0), false);
	ASSERT_EQ(poly_avx_128_check(in, out, 7), false);
	ASSERT_EQ(poly_avx_128_check(in, NULL, MAX_SIZE), false);
	ASSERT_EQ(poly_avx_128_check(NULL, out, MAX_SIZE), false);
}

TEST(avx_3, poly_avx_256)
{
	init_sources();
	ASSERT_EQ(poly_avx_256_check(in, out, MAX_SIZE), true);
	for (int i = 0; i < MAX_SIZE; i++) {
		float sq = in[i] * in[i];
		float cb = sq * in[i];
		ASSERT_FLOAT_EQ(sq + cb + in[i], out[i]);
	}
	ASSERT_EQ(poly_avx_256_check(in, out, 0), false);
	ASSERT_EQ(poly_avx_256_check(in, out, 7), false);
	ASSERT_EQ(poly_avx_256_check(in, NULL, MAX_SIZE), false);
	ASSERT_EQ(poly_avx_256_check(NULL, out, MAX_SIZE), false);
}
