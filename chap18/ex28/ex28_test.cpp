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

#include "adj_load_masked_broadcast.h"
#include "adj_vpgatherpd.h"
#include "elem_struct.h"
#include "optimisation_common.h"

const int MAX_SIZE = 4096;

static int32_t indices[MAX_SIZE];
static double c_out[MAX_SIZE * (sizeof(elem_struct_t) / sizeof(double))];

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static elem_struct_t in[MAX_SIZE];
__declspec(align(
    64)) static double out[MAX_SIZE * (sizeof(elem_struct_t) / sizeof(double))];
#else
static elem_struct_t in[MAX_SIZE] __attribute__((aligned(64)));
static double out[MAX_SIZE * (sizeof(elem_struct_t) / sizeof(double))]
    __attribute__((aligned(64)));
#endif

void init_sources()
{
	for (int32_t i = 0; i < MAX_SIZE; i++) {
		for (size_t j = 0; j < 4; j++)
			in[i].var[j] = ((double)rand()) / RAND_MAX;
		indices[i] = i;
	}

	for (size_t i = 0; i < MAX_SIZE; i++) {
		size_t a = rand() % MAX_SIZE;
		size_t b = rand() % MAX_SIZE;
		int32_t tmp = indices[a];
		indices[a] = indices[b];
		indices[b] = tmp;
	}

	for (int i = 0; i < MAX_SIZE; i++) {
		for (int j = 0; j < 4; j++) {
			c_out[i * 4 + j] = in[indices[i]].var[j];
		}
	}
}

TEST(avx512_28, vgatherdpd)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(adj_vpgatherpd_check(MAX_SIZE, indices, in, out), true);
	for (int i = 0; i < MAX_SIZE * 4; i++)
		ASSERT_EQ(c_out[i], out[i]);
	ASSERT_EQ(adj_vpgatherpd_check(7, indices, in, out), false);
	ASSERT_EQ(adj_vpgatherpd_check(MAX_SIZE, NULL, in, out), false);
	ASSERT_EQ(adj_vpgatherpd_check(MAX_SIZE, indices, NULL, out), false);
	ASSERT_EQ(adj_vpgatherpd_check(MAX_SIZE, indices, in, NULL), false);
}

TEST(avx512_28, adj_load_masked_broadcast_check)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(adj_load_masked_broadcast_check(MAX_SIZE, indices, in, out),
		  true);
	for (int i = 0; i < MAX_SIZE * 4; i++)
		ASSERT_EQ(c_out[i], out[i]);
	ASSERT_EQ(adj_load_masked_broadcast_check(7, indices, in, out), false);
	ASSERT_EQ(adj_load_masked_broadcast_check(MAX_SIZE, NULL, in, out),
		  false);
	ASSERT_EQ(adj_load_masked_broadcast_check(MAX_SIZE, indices, NULL, out),
		  false);
	ASSERT_EQ(adj_load_masked_broadcast_check(MAX_SIZE, indices, in, NULL),
		  false);
}
