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

#include <stdint.h>

#include "gtest/gtest.h"

#include "avx2_min_max.h"
#include "mmx_min_max.h"

const int MAX_SIZE = 4096;

static int16_t in[MAX_SIZE];

static void init_sources()
{
	for (int16_t i = 0; i < MAX_SIZE; i++)
		in[i] = i - (MAX_SIZE / 2);

	for (size_t i = 0; i < MAX_SIZE; i++) {
		size_t x = rand() % MAX_SIZE;
		size_t y = rand() % MAX_SIZE;
		int16_t tmp = in[x];
		in[x] = in[y];
		in[y] = tmp;
	}
}

TEST(avx_48, mmx_min_max)
{
	min_max res;

	res.max = 0;
	res.min = 0;
	init_sources();
	ASSERT_EQ(mmx_min_max_check(in, &res, MAX_SIZE), true);
	ASSERT_EQ(res.max, (MAX_SIZE - (MAX_SIZE / 2) - 1));
	ASSERT_EQ(res.min, -(MAX_SIZE / 2));
	ASSERT_EQ(mmx_min_max_check(NULL, &res, MAX_SIZE), false);
	ASSERT_EQ(mmx_min_max_check(in, NULL, MAX_SIZE), false);
	ASSERT_EQ(mmx_min_max_check(in, &res, 3), false);
	ASSERT_EQ(mmx_min_max_check(in, &res, 19), false);
}

TEST(avx_48, avx2_min_max)
{
	min_max res;

	res.max = 0;
	res.min = 0;
	init_sources();
	ASSERT_EQ(avx2_min_max_check(in, &res, MAX_SIZE), true);
	ASSERT_EQ(res.max, (MAX_SIZE - (MAX_SIZE / 2) - 1));
	ASSERT_EQ(res.min, -(MAX_SIZE / 2));
	ASSERT_EQ(avx2_min_max_check(NULL, &res, MAX_SIZE), false);
	ASSERT_EQ(avx2_min_max_check(in, NULL, MAX_SIZE), false);
	ASSERT_EQ(avx2_min_max_check(in, &res, 16), false);
	ASSERT_EQ(avx2_min_max_check(in, &res, 48), false);
}
