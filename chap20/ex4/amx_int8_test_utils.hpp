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

#ifndef AMX_INT8_TEST_UTILS_HPP
#define AMX_INT8_TEST_UTILS_HPP

type_t B_mem_orig[K][N];
res_type_t C_mem_expected[M][N];

static int8_t next_int8(int8_t i)
{
	if (i == 127)
		return -128;
	return i + 1;
}

static void init_sources()
{
	int8_t counter = -128;

	memset(C_mem, 0, sizeof(C_mem));

	for (size_t m = 0; m < M; m++) {
		for (size_t k = 0; k < K; k++) {
			A_mem[m][k] = counter;
			counter = next_int8(counter);
		}
	}

	for (size_t k = 0; k < K; k++) {
		for (size_t n = 0; n < N; n++) {
			B_mem_orig[k][n] = counter;
			counter = next_int8(counter);
		}
	}

	for (size_t m = 0; m < M; m++)
		for (size_t n = 0; n < N; n++)
			for (size_t k = 0; k < K; k++)
				C_mem_expected[m][n] +=
                                        ((int32_t) A_mem[m][k]) * ((int32_t) B_mem_orig[k][n]);
}

static void amx_ref_gemm_int8()
{
	/*
	 * re-layout code from Code Listing 2
	 */

	for (int k = 0; k < K; ++k)
		for (int n = 0; n < N; ++n)
			B_mem[k / KPACK][n][k % KPACK] = B_mem_orig[k][n];

	amx_ref_gemm();
}

#endif
