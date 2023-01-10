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

extern "C" unsigned int get_complex_mask_from_real_mask_or(unsigned int m);

TEST(fp16_3, complex_from_real_mask_or)
{
	const std::array<std::pair<unsigned int, unsigned int>, 16> tests = {{
	    {0x0, 0x0},
	    {0x3, 0x1},
	    {0xc, 0x2},
	    {0xf, 0x3},
	    {0x30, 0x4},
	    {0x33, 0x5},
	    {0x3c, 0x6},
	    {0x3f, 0x7},
	    {0xc0, 0x8},
	    {0xc3, 0x9},
	    {0xcc, 0xa},
	    {0xcf, 0xb},
	    {0xf0, 0xc},
	    {0xf3, 0xd},
	    {0xfc, 0xe},
	    {0xff, 0xf},
	}};

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	for (const auto &p : tests) {
		ASSERT_EQ(get_complex_mask_from_real_mask_or(p.first),
			  p.second);
	}
}
