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

#include "vpgatherd_soft.h"

const int MAX_SIZE = 8;

static uint32_t in[MAX_SIZE];
static uint32_t indices[MAX_SIZE];
static uint32_t out[MAX_SIZE];

static void init_sources()
{
	for (uint32_t i = 0; i < MAX_SIZE; i++) {
		in[i] = i + 1;
		indices[i] = MAX_SIZE - (i + 1);
		out[i] = 0;
	}
}

TEST(avx_45, copy8)
{
	init_sources();
	ASSERT_EQ(vpgatherd_soft8_check(indices, in, out), true);
	for (size_t i = 0; i < MAX_SIZE; i++)
		ASSERT_EQ(in[i], out[MAX_SIZE - (i + 1)]);

	ASSERT_EQ(vpgatherd_soft8_check(NULL, in, out), false);
	ASSERT_EQ(vpgatherd_soft8_check(indices, NULL, out), false);
	ASSERT_EQ(vpgatherd_soft8_check(indices, in, NULL), false);
}
