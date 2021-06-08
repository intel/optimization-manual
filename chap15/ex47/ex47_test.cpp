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

#include "avx2_gatherpd.h"
#include "avx_vinsert.h"

const int MAX_SIZE = 4096;

static complex_num aos[MAX_SIZE];
static double soa_real[MAX_SIZE];
static double soa_imaginary[MAX_SIZE];
static uint32_t indices[MAX_SIZE];

void init_sources()
{
	for (uint32_t i = 0; i < MAX_SIZE; i++) {
		indices[i] = MAX_SIZE - (i + 1);
		aos[i].real = (double)i;
		aos[i].imaginary = (double)i + 1;
	}
}

TEST(avx_47, avx2_gatherpd)
{
	init_sources();
	ASSERT_EQ(avx2_gatherpd_check(MAX_SIZE, indices, soa_imaginary,
				      soa_real, aos),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_DOUBLE_EQ(aos[i].real, soa_real[MAX_SIZE - (i + 1)]);
		ASSERT_DOUBLE_EQ(aos[i].imaginary,
				 soa_imaginary[MAX_SIZE - (i + 1)]);
	}
	ASSERT_EQ(avx2_gatherpd_check(0, indices, soa_imaginary, soa_real, aos),
		  false);
	ASSERT_EQ(
	    avx2_gatherpd_check(12, indices, soa_imaginary, soa_real, aos),
	    false);
	ASSERT_EQ(
	    avx2_gatherpd_check(MAX_SIZE, NULL, soa_imaginary, soa_real, aos),
	    false);
	ASSERT_EQ(avx2_gatherpd_check(MAX_SIZE, indices, NULL, soa_real, aos),
		  false);
	ASSERT_EQ(
	    avx2_gatherpd_check(MAX_SIZE, indices, soa_imaginary, NULL, aos),
	    false);
	ASSERT_EQ(avx2_gatherpd_check(MAX_SIZE, indices, soa_imaginary,
				      soa_real, NULL),
		  false);
}

TEST(avx_47, avx_vinsert)
{
	init_sources();
	ASSERT_EQ(
	    avx_vinsert_check(MAX_SIZE, indices, soa_imaginary, soa_real, aos),
	    true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_DOUBLE_EQ(aos[i].real, soa_real[MAX_SIZE - (i + 1)]);
		ASSERT_DOUBLE_EQ(aos[i].imaginary,
				 soa_imaginary[MAX_SIZE - (i + 1)]);
	}
	ASSERT_EQ(avx_vinsert_check(0, indices, soa_imaginary, soa_real, aos),
		  false);
	ASSERT_EQ(avx_vinsert_check(13, indices, soa_imaginary, soa_real, aos),
		  false);
	ASSERT_EQ(
	    avx_vinsert_check(MAX_SIZE, NULL, soa_imaginary, soa_real, aos),
	    false);
	ASSERT_EQ(avx_vinsert_check(MAX_SIZE, indices, NULL, soa_real, aos),
		  false);
	ASSERT_EQ(
	    avx_vinsert_check(MAX_SIZE, indices, soa_imaginary, NULL, aos),
	    false);
	ASSERT_EQ(
	    avx_vinsert_check(MAX_SIZE, indices, soa_imaginary, soa_real, NULL),
	    false);
}
