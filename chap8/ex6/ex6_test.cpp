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

#include <cmath>
#include <cstdlib>

#include "eltwise.h"
#include "optimisation_common.h"

TEST(vnni, post_conv)
{
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(16)) int8_t res8s[16];
	__declspec(align(16)) int8_t res8v[16];
#else
	int8_t res8s[16] __attribute__((aligned(16)));
	int8_t res8v[16] __attribute__((aligned(16)));
#endif

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	srand(0);

	test_eltwise(res8s, res8v);

	for (size_t i = 0; i < 16; i++) {
		ASSERT_EQ(res8s[i], res8v[i]);
	}
}
