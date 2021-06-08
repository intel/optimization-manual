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

#include "gtest/gtest.h"

#include "divps_sse.h"
#include "vdivps_avx.h"

const int MAX_SIZE = 24; /* Must divisible by 8 */

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float x[MAX_SIZE];
__declspec(align(32)) static float y[MAX_SIZE];
__declspec(align(32)) static float z[MAX_SIZE];
#else
static float x[MAX_SIZE] __attribute__((aligned(32)));
static float y[MAX_SIZE] __attribute__((aligned(32)));
static float z[MAX_SIZE] __attribute__((aligned(32)));
#endif

void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		x[i] = i * 1.0f;
		y[i] = (MAX_SIZE - i) * 1.0f;
		z[i] = 0.0f;
	}
}

TEST(avx_22, divps_sse)
{
	init_sources();
	ASSERT_EQ(divps_sse_check(x, y, z, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(x[i] / y[i], z[i]);
	}
	ASSERT_EQ(divps_sse_check(NULL, y, z, MAX_SIZE), false);
	ASSERT_EQ(divps_sse_check(x, NULL, z, MAX_SIZE), false);
	ASSERT_EQ(divps_sse_check(x, y, NULL, MAX_SIZE), false);
	ASSERT_EQ(divps_sse_check(x, y, z, MAX_SIZE - 2), false);
	ASSERT_EQ(divps_sse_check(x, y, z, 0), false);
}

TEST(avx_22, vdivps_avx)
{
	init_sources();
	ASSERT_EQ(vdivps_avx_check(x, y, z, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(x[i] / y[i], z[i]);
	}
	ASSERT_EQ(vdivps_avx_check(NULL, y, z, MAX_SIZE), false);
	ASSERT_EQ(vdivps_avx_check(x, NULL, z, MAX_SIZE), false);
	ASSERT_EQ(vdivps_avx_check(x, y, NULL, MAX_SIZE), false);
	ASSERT_EQ(vdivps_avx_check(x, y, z, MAX_SIZE - 4), false);
	ASSERT_EQ(vdivps_avx_check(x, y, z, 0), false);
}
