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

#include "i64toa_avx2.h"

TEST(avx_41, i6toa_avx2i)
{
	char buf[128];
	char expected[128];
	size_t j;
	int64_t num;
	int64_t mul;

	for (size_t i = 0; i < 19; i++) {
		num = 0;
		mul = 1;
		for (j = 0; j <= i; j++) {
			expected[j] = ((j + 1) % 10) + '0';
			num += (((i - j) + 1) % 10) * mul;
			mul *= 10;
		}
		expected[j] = 0;
		ASSERT_EQ(i64toa_avx2i_check(num, buf), true);
		ASSERT_STREQ(buf, expected);
	}

	ASSERT_EQ(i64toa_avx2i_check(-9223372036854775807ll, buf), true);
	ASSERT_STREQ(buf, "9223372036854775807");
	ASSERT_EQ(i64toa_avx2i_check(-9223372036854775807ll, NULL), false);
}
