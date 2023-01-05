/*
 * Copyright (C) 2022 by Intel Corporation
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

#include <array>
#include <utility>

#include "optimisation_common.h"

extern "C" unsigned int get_real_mask_from_complex_mask(unsigned int m);

TEST(fp16_1, real_from_complex_mask)
{
	const std::array<std::pair<unsigned int, unsigned int>, 16> tests = {{
	    {0x0, 0x0},
	    {0x1, 0x3},
	    {0x2, 0xc},
	    {0x3, 0xf},
	    {0x4, 0x30},
	    {0x5, 0x33},
	    {0x6, 0x3c},
	    {0x7, 0x3f},
	    {0x8, 0xc0},
	    {0x9, 0xc3},
	    {0xa, 0xcc},
	    {0xb, 0xcf},
	    {0xc, 0xf0},
	    {0xd, 0xf3},
	    {0xe, 0xfc},
	    {0xf, 0xff},
	}};

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	for (const auto &p : tests) {
		ASSERT_EQ(get_real_mask_from_complex_mask(p.first), p.second);
	}
}
