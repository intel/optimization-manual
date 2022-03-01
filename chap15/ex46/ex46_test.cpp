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

#include "avx2_vpgatherd.h"
#include "avx_vinsrt.h"
#include "scalar.h"

const int MAX_SIZE = 4096;

static complex_num aos[MAX_SIZE];
static float soa_real[MAX_SIZE];
static float soa_imaginary[MAX_SIZE];

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		aos[i].real = (float)i;
		aos[i].imaginary = (float)i + 1;
		soa_real[i] = 0.0;
		soa_imaginary[i] = 0.0;
	}
}

TEST(avx_46, scalar)
{
	init_sources();
	ASSERT_EQ(scalar_check(MAX_SIZE, aos, soa_imaginary, soa_real), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(aos[i].real, soa_real[i]);
		ASSERT_FLOAT_EQ(aos[i].imaginary, soa_imaginary[i]);
	}
	ASSERT_EQ(scalar_check(0, aos, soa_imaginary, soa_real), false);
	ASSERT_EQ(scalar_check(3, aos, soa_imaginary, soa_real), false);
	ASSERT_EQ(scalar_check(MAX_SIZE, NULL, soa_imaginary, soa_real), false);
	ASSERT_EQ(scalar_check(MAX_SIZE, aos, NULL, soa_real), false);
	ASSERT_EQ(scalar_check(MAX_SIZE, aos, soa_imaginary, NULL), false);
}

TEST(avx_46, avx_vinsrt)
{
	init_sources();
	ASSERT_EQ(avx_vinsrt_check(MAX_SIZE, aos, soa_imaginary, soa_real),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(aos[i].real, soa_real[i]);
		ASSERT_FLOAT_EQ(aos[i].imaginary, soa_imaginary[i]);
	}
	ASSERT_EQ(avx_vinsrt_check(0, aos, soa_imaginary, soa_real), false);
	ASSERT_EQ(avx_vinsrt_check(8, aos, soa_imaginary, soa_real), false);
	ASSERT_EQ(avx_vinsrt_check(MAX_SIZE, NULL, soa_imaginary, soa_real),
		  false);
	ASSERT_EQ(avx_vinsrt_check(MAX_SIZE, aos, NULL, soa_real), false);
	ASSERT_EQ(avx_vinsrt_check(MAX_SIZE, aos, soa_imaginary, NULL), false);
}

TEST(avx_46, avx2_vpgatherd)
{
	init_sources();
	ASSERT_EQ(avx2_vpgatherd_check(MAX_SIZE, aos, soa_imaginary, soa_real),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(aos[i].real, soa_real[i]);
		ASSERT_FLOAT_EQ(aos[i].imaginary, soa_imaginary[i]);
	}
	ASSERT_EQ(avx2_vpgatherd_check(0, aos, soa_imaginary, soa_real), false);
	ASSERT_EQ(avx2_vpgatherd_check(12, aos, soa_imaginary, soa_real),
		  false);
	ASSERT_EQ(avx2_vpgatherd_check(MAX_SIZE, NULL, soa_imaginary, soa_real),
		  false);
	ASSERT_EQ(avx2_vpgatherd_check(MAX_SIZE, aos, NULL, soa_real), false);
	ASSERT_EQ(avx2_vpgatherd_check(MAX_SIZE, aos, soa_imaginary, NULL),
		  false);
}
