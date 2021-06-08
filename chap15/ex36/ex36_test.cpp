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

#include "no_unroll_reduce.h"
#include "unroll_reduce.h"

const int MAX_SIZE = 4096;

static float a[MAX_SIZE];

void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++)
		a[i] = i + 1.0f;
}

TEST(avx_36, no_unroll_reduce)
{
	init_sources();
	float res;
	ASSERT_EQ(no_unroll_reduce_check(a, MAX_SIZE, &res), true);
	ASSERT_FLOAT_EQ(res, (MAX_SIZE * (MAX_SIZE + 1)) / 2.0);
	ASSERT_EQ(no_unroll_reduce_check(NULL, MAX_SIZE, &res), false);
	ASSERT_EQ(no_unroll_reduce_check(a, 8, &res), false);
	ASSERT_EQ(no_unroll_reduce_check(a, 17, &res), false);
}

TEST(avx_36, unroll_reduce)
{
	init_sources();
	float res;
	ASSERT_EQ(unroll_reduce_check(a, MAX_SIZE, &res), true);
	ASSERT_FLOAT_EQ(res, (MAX_SIZE * (MAX_SIZE + 1)) / 2.0);
	ASSERT_EQ(unroll_reduce_check(NULL, MAX_SIZE, &res), false);
	ASSERT_EQ(unroll_reduce_check(NULL, 64, &res), false);
	ASSERT_EQ(unroll_reduce_check(NULL, 132, &res), false);
}
