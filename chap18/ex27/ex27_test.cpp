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

#include "optimisation_common.h"
#include "s2s_vpermi2d.h"
#include "s2s_vscatterdps.h"

const int MAX_SIZE = 4096;

static complex_num aos[MAX_SIZE];
static float soa_real[MAX_SIZE];
static float soa_imaginary[MAX_SIZE];

void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		soa_real[i] = (float)i;
		soa_imaginary[i] = (float)i + 1;
		aos[i].real = 0.0;
		aos[i].imaginary = 0.0;
	}
}

TEST(avx512_27, s2s_vscatterdps)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(s2s_vscatterdps_check(MAX_SIZE, soa_imaginary, soa_real, aos),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(aos[i].real, soa_real[i]);
		ASSERT_FLOAT_EQ(aos[i].imaginary, soa_imaginary[i]);
	}
	ASSERT_EQ(s2s_vscatterdps_check(7, soa_imaginary, soa_real, aos),
		  false);
	ASSERT_EQ(s2s_vscatterdps_check(17, soa_imaginary, soa_real, aos),
		  false);
	ASSERT_EQ(s2s_vscatterdps_check(MAX_SIZE, NULL, soa_real, aos), false);
	ASSERT_EQ(s2s_vscatterdps_check(MAX_SIZE, soa_imaginary, NULL, aos),
		  false);
	ASSERT_EQ(
	    s2s_vscatterdps_check(MAX_SIZE, soa_imaginary, soa_real, NULL),
	    false);
}

TEST(avx512_27, s2s_vpermi2d)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	ASSERT_EQ(s2s_vpermi2d_check(MAX_SIZE, soa_imaginary, soa_real, aos),
		  true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_FLOAT_EQ(aos[i].real, soa_real[i]);
		ASSERT_FLOAT_EQ(aos[i].imaginary, soa_imaginary[i]);
	}
	ASSERT_EQ(s2s_vpermi2d_check(7, soa_imaginary, soa_real, aos), false);
	ASSERT_EQ(s2s_vpermi2d_check(17, soa_imaginary, soa_real, aos), false);
	ASSERT_EQ(s2s_vpermi2d_check(MAX_SIZE, NULL, soa_real, aos), false);
	ASSERT_EQ(s2s_vpermi2d_check(MAX_SIZE, soa_imaginary, NULL, aos),
		  false);
	ASSERT_EQ(s2s_vpermi2d_check(MAX_SIZE, soa_imaginary, soa_real, NULL),
		  false);
}
