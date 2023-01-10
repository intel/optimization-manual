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

#ifdef COMPILER_SUPPORTS_AMX

#include "amx_ref_gemm_int8_uint8.hpp"
#include "../ex1/amx_tile.hpp"
#include "gemm/amx_post_conv_gemm_relu_ass.hpp"
#include "amx_int8_uint8_test_utils.hpp"
#include "optimisation_common.h"

// clang-format on

TEST(amx_17, amx_interleaved_gemm_int8_relu)
{
	if (!supports_amx())
		GTEST_SKIP_("AMX not supported, skipping test");

	init_sources();

	amx_ref_gemm_int8_uint8();

	for (size_t m = 0; m < M; m++)
		for (size_t n = 0; n < N; n++) {
			ASSERT_EQ(C_tmp_mem_expected[m][n], C_tmp_mem[m][n]);
			ASSERT_EQ(C_mem_expected[m][n], C_mem[m][n]);
		}
}
#else
TEST(amx_17, amx_interleaved_gemm_int8_relu)
{
	GTEST_SKIP_("Compiler does not support AMX, skipping test");
}
#endif
