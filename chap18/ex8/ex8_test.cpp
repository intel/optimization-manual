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

#include <xmmintrin.h>

#include "gtest/gtest.h"

#include "mce_avx2.h"
#include "mce_avx512.h"
#include "mce_scalar.h"
#include "optimisation_common.h"

const size_t MAX_SIZE = 4096;

#ifdef _MSC_VER
__declspec(align(64)) static uint32_t in_image[MAX_SIZE];
__declspec(align(64)) static uint32_t c_image[MAX_SIZE];
__declspec(align(64)) static uint32_t asm_image[MAX_SIZE];
#else
static uint32_t in_image[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t c_image[MAX_SIZE] __attribute__((aligned(64)));
static uint32_t asm_image[MAX_SIZE] __attribute__((aligned(64)));
#endif

static void init_sources()
{
	for (size_t i = 0; i < MAX_SIZE; i++)
		in_image[i] = i & 0xff;
}

static void multiple_condition_execution(uint32_t *pRefImage,
					 const uint32_t *pInImage,
					 int iBufferWidth)
{
	for (int iX = 0; iX < iBufferWidth; iX++) {
		if ((*pInImage) > 0 && ((*pInImage) & 3) == 3) {
			*pRefImage = (*pInImage) + 5;
		} else {
			*pRefImage = (*pInImage);
		}
		pRefImage++;
		pInImage++;
	}
}

TEST(avx512_8, mce_scalar)
{
	init_sources();
	multiple_condition_execution(c_image, in_image, MAX_SIZE);
	memset(asm_image, 0, sizeof(asm_image));
	ASSERT_EQ(mce_scalar_check(asm_image, in_image, MAX_SIZE), true);
	;
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(c_image[i], asm_image[i]);
	}
	ASSERT_EQ(mce_scalar_check(NULL, in_image, MAX_SIZE), false);
	;
	ASSERT_EQ(mce_scalar_check(asm_image, NULL, MAX_SIZE), false);
	;
	ASSERT_EQ(mce_scalar_check(asm_image, in_image, 0), false);
	;
}

TEST(avx512_8, mce_avx2)
{
	init_sources();
	multiple_condition_execution(c_image, in_image, MAX_SIZE);
	memset(asm_image, 0, sizeof(asm_image));
	ASSERT_EQ(mce_avx2_check(asm_image, in_image, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(c_image[i], asm_image[i]);
	}
	ASSERT_EQ(mce_avx2_check(NULL, in_image, MAX_SIZE), false);
	ASSERT_EQ(mce_avx2_check(asm_image, NULL, MAX_SIZE), false);
	ASSERT_EQ(mce_avx2_check(asm_image + 4, in_image, MAX_SIZE), false);
	ASSERT_EQ(mce_avx2_check(asm_image, in_image + 4, MAX_SIZE), false);
	ASSERT_EQ(mce_avx2_check(asm_image, in_image, MAX_SIZE - 4), false);
}

TEST(avx512_8, mce_avx512)
{
	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	init_sources();
	multiple_condition_execution(c_image, in_image, MAX_SIZE);
	memset(asm_image, 0, sizeof(asm_image));
	ASSERT_EQ(mce_avx512_check(asm_image, in_image, MAX_SIZE), true);
	for (size_t i = 0; i < MAX_SIZE; i++) {
		ASSERT_EQ(c_image[i], asm_image[i]);
	}
	ASSERT_EQ(mce_avx512_check(NULL, in_image, MAX_SIZE), false);
	ASSERT_EQ(mce_avx512_check(asm_image, NULL, MAX_SIZE), false);
	ASSERT_EQ(mce_avx512_check(asm_image + 8, in_image, MAX_SIZE), false);
	ASSERT_EQ(mce_avx512_check(asm_image, in_image + 8, MAX_SIZE), false);
	ASSERT_EQ(mce_avx512_check(asm_image, in_image, MAX_SIZE - 8), false);
}
