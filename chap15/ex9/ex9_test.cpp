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

#include "scatter_avx.h"
#include "scatter_scalar.h"

/* init_sources expects MAX_SIZE to be > 1  and divisible by 2 */
const int MAX_SIZE = 4096;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static int32_t in[MAX_SIZE];
__declspec(align(32)) static int32_t out[MAX_SIZE];
__declspec(align(32)) static uint32_t indices[MAX_SIZE];
#else
static int32_t in[MAX_SIZE] __attribute__((aligned(32)));
static int32_t out[MAX_SIZE] __attribute__((aligned(32)));
static uint32_t indices[MAX_SIZE] __attribute__((aligned(32)));
#endif
void init_sources()
{
	for (int i = 0; i < MAX_SIZE; i++) {
		in[i] = i - (MAX_SIZE / 2);
		out[i] = 0;
		indices[i] = i & 1 ? i - 1 : i + 1;
	}
}

TEST(avx_9, scatter_scalar)
{
	init_sources();
	ASSERT_EQ(scatter_scalar_check(in, out, indices, MAX_SIZE), true);
	for (int i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(in[indices[i]], out[i]);
	}
	ASSERT_EQ(scatter_scalar_check(NULL, out, indices, MAX_SIZE), false);
	ASSERT_EQ(scatter_scalar_check(in, NULL, indices, MAX_SIZE), false);
	ASSERT_EQ(scatter_scalar_check(in, out, NULL, MAX_SIZE), false);
	ASSERT_EQ(scatter_scalar_check(in, out, NULL, MAX_SIZE - 2), false);
}

TEST(avx_9, scatter_avx)
{
	init_sources();
	ASSERT_EQ(scatter_avx_check(in, out, indices, MAX_SIZE), true);
	for (int i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(in[indices[i]], out[i]);
	}
	ASSERT_EQ(scatter_avx_check(NULL, out, indices, MAX_SIZE), false);
	ASSERT_EQ(scatter_avx_check(in, NULL, indices, MAX_SIZE), false);
	ASSERT_EQ(scatter_avx_check(in, out, NULL, MAX_SIZE), false);
	ASSERT_EQ(scatter_avx_check(in + 2, out, indices, MAX_SIZE), false);
	ASSERT_EQ(scatter_avx_check(in, out, indices, MAX_SIZE - 2), false);
}
