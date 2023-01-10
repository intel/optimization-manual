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

// clang-format off

#include "../ex13/amx_conv_int8.hpp"
#include "../ex1/amx_tile.hpp"
#include "amx_conv_int8_test_utils.hpp"
#include "gemm/amx_conv_gemm.hpp"

// clang-format on

TEST(amx_14, amx_conv_int8)
{
	init_sources();

	amx_conv_gemm();

	for (size_t i = 0; i < MC; i++)
		for (size_t j = 0; j < N; j++)
			ASSERT_EQ(C_mem[i][j], C_mem_expected[j][i]);
}
