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

#include <iostream>

#include "supports_avx2.h"
#include "gtest/gtest.h"

TEST(simd_15, supports_avx2)
{
	/*
	 * supports_avx2 can legitimately return true or false depending
	 * the machine on which the test is run.  So we're just going to
	 * call the function to make sure it doesn't crash.  The other
	 * avx2 tests will also call this function it will be properly
	 * tested that way.
	 */

	int64_t result = supports_avx2();
	std::cerr << "Supports AVX2: " << result << std::endl;
}
