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

#include "vinsertps_transpose.h"

const int MAX_SIZE = 8; /* Must divisible by 8 */

struct unaligned_matrix {
	float dummy;
	float x[MAX_SIZE][MAX_SIZE];
};

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(32)) static float x[MAX_SIZE][MAX_SIZE];
__declspec(align(32)) static float y[MAX_SIZE][MAX_SIZE];
__declspec(align(32)) static unaligned_matrix unaligned_m;
#else
static float x[MAX_SIZE][MAX_SIZE] __attribute__((aligned(32)));
static float y[MAX_SIZE][MAX_SIZE] __attribute__((aligned(32)));
static unaligned_matrix unaligned_m __attribute__((aligned(32)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++)
		for (size_t j = 0; j < MAX_SIZE; j++) {
			x[i][j] = (float)i * MAX_SIZE + j;
			unaligned_m.x[i][j] = x[i][j];
			y[i][j] = 0.0;
		}
}

static void prv_check_result(void)
{
	for (size_t i = 0; i < MAX_SIZE; i++) {
		for (size_t j = 0; j < MAX_SIZE; j++) {
			ASSERT_EQ(static_cast<float>(i + (j * MAX_SIZE)),
				  y[i][j]);
		}
	}
}

TEST(avx_20, vinsertps_transpose)
{
	init_sources();
	ASSERT_EQ(vinsertps_transpose_check(x, y, 1), true);
	prv_check_result();
	ASSERT_EQ(vinsertps_transpose_check(NULL, y, 1), false);
	ASSERT_EQ(vinsertps_transpose_check(x, NULL, 1), false);
	ASSERT_EQ(vinsertps_transpose_check(x, y, 0), false);
	ASSERT_EQ(vinsertps_transpose_check(unaligned_m.x, y, 1), false);
	ASSERT_EQ(vinsertps_transpose_check(x, unaligned_m.x, 1), false);
}
