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
#include "pooling.h"

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) float outputFeatureMaps[16];
#else
float outputFeatureMaps[16] __attribute__((aligned(64)));
#endif

TEST(vnni, pooling)
{
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(64)) float expected[16];
#else
	float expected[16] __attribute__((aligned(64)));
#endif

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	test_pooling(outputFeatureMaps, expected);

	for (size_t i = 0; i < 16; i++) {
		ASSERT_FLOAT_EQ(expected[i], outputFeatureMaps[i]);
	}
}
