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

#include "lookup_novbmi.h"
#include "lookup_vbmi.h"
#include "optimisation_common.h"

const int MAX_SIZE = 1024;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) static unsigned char a[MAX_SIZE];
__declspec(align(64)) static unsigned char b[64];
__declspec(align(64)) static unsigned char out[MAX_SIZE];
__declspec(align(64)) static unsigned char c_out[MAX_SIZE];
#else
static unsigned char a[MAX_SIZE] __attribute__((aligned(64)));
static unsigned char b[64] __attribute__((aligned(64)));
static unsigned char out[MAX_SIZE] __attribute__((aligned(64)));
static unsigned char c_out[MAX_SIZE] __attribute__((aligned(64)));
#endif

void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		a[i] = static_cast<uint8_t>(i % 255);
		out[i] = static_cast<uint8_t>(0);
		c_out[i] = static_cast<uint8_t>(0);
	}
	for (size_t i = 0; i < 64; i++) {
		b[i] = static_cast<uint8_t>(63 - i);
	}
}

void lookup(unsigned char *in_bytes, unsigned char *out_bytes,
	    unsigned char *dictionary_bytes, int numOfElements)
{
	for (int i = 0; i < numOfElements; i++) {
		out_bytes[i] = dictionary_bytes[in_bytes[i] & 63];
	}
}

TEST(avx512_21, lookup_novbmi)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	lookup(a, c_out, b, MAX_SIZE);
	ASSERT_EQ(lookup_novbmi_check(a, b, out, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(c_out[i], out[i]);
	}

	ASSERT_EQ(lookup_novbmi_check(NULL, b, out, MAX_SIZE), false);
	ASSERT_EQ(lookup_novbmi_check(a, NULL, out, MAX_SIZE), false);
	ASSERT_EQ(lookup_novbmi_check(a, b, NULL, MAX_SIZE), false);
	ASSERT_EQ(lookup_novbmi_check(a, b, out, MAX_SIZE - 16), false);
}

TEST(avx512_21, lookup_vbmi)
{
	if (!supports_avx512_icl())
		GTEST_SKIP_("VBMI not supported, skipping test");

	init_sources();
	lookup(a, c_out, b, MAX_SIZE);
	ASSERT_EQ(lookup_vbmi_check(a, b, out, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(c_out[i], out[i]);
	}

	ASSERT_EQ(lookup_vbmi_check(NULL, b, out, MAX_SIZE), false);
	ASSERT_EQ(lookup_vbmi_check(a, NULL, out, MAX_SIZE), false);
	ASSERT_EQ(lookup_vbmi_check(a, b, NULL, MAX_SIZE), false);
	ASSERT_EQ(lookup_vbmi_check(a, b, out, MAX_SIZE + 16), false);
}
