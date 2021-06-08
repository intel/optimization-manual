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

#include "complex_conv_avx_stride.h"
#include "complex_conv_sse.h"

const int MAX_SIZE = 4096;

static complex_num aos[MAX_SIZE];
static float soa_real[MAX_SIZE];
static float soa_imaginary[MAX_SIZE];

void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		aos[i].real = (float)i;
		aos[i].imaginary = (float)i + 1;
		soa_real[i] = 0.0;
		soa_imaginary[i] = 0.0;
	}
}

TEST(avx_6, complex_conv_sse)
{
	init_sources();
	ASSERT_EQ(
	    complex_conv_sse_check(aos, soa_real, soa_imaginary, MAX_SIZE),
	    true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(aos[i].real, soa_real[i]);
		ASSERT_FLOAT_EQ(aos[i].imaginary, soa_imaginary[i]);
	}
	ASSERT_EQ(complex_conv_sse_check(aos, soa_real, NULL, MAX_SIZE), false);
	ASSERT_EQ(complex_conv_sse_check(aos, NULL, soa_imaginary, MAX_SIZE),
		  false);
	ASSERT_EQ(
	    complex_conv_sse_check(NULL, soa_real, soa_imaginary, MAX_SIZE),
	    false);
	ASSERT_EQ(complex_conv_sse_check(aos, soa_real, soa_imaginary, 3),
		  false);
}

TEST(avx_6, complex_conv_avx_stride)
{
	init_sources();
	ASSERT_EQ(complex_conv_avx_stride_check(aos, soa_real, soa_imaginary,
						MAX_SIZE),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(aos[i].real, soa_real[i]);
		ASSERT_FLOAT_EQ(aos[i].imaginary, soa_imaginary[i]);
	}
	ASSERT_EQ(complex_conv_avx_stride_check(aos, soa_real, NULL, MAX_SIZE),
		  false);
	ASSERT_EQ(
	    complex_conv_avx_stride_check(aos, NULL, soa_imaginary, MAX_SIZE),
	    false);
	ASSERT_EQ(complex_conv_avx_stride_check(NULL, soa_real, soa_imaginary,
						MAX_SIZE),
		  false);
	ASSERT_EQ(
	    complex_conv_avx_stride_check(aos, soa_real, soa_imaginary, 3),
	    false);
}
