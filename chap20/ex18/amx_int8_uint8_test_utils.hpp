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

#ifndef AMX_INT8_UINT8_TEST_UTILS_HPP
#define AMX_INT8_UINT8_TEST_UTILS_HPP

#include <math.h>

btype_t B_mem_orig[K][N];
res_type_t C_tmp_mem_out_expected[M][N];
atype_t C_mem_expected[M][N];

static void init_a_and_b(uint8_t &max_a, int8_t &max_b)
{
	for (size_t m = 0; m < M; m++)
		for (size_t k = 0; k < K; k++) {
			A_mem[m][k] = 96 + (rand() % 64);
			if (A_mem[m][k] > max_a)
				max_a = A_mem[m][k];
		}

	for (size_t k = 0; k < K; k++)
		for (size_t n = 0; n < N; n++) {
			B_mem_orig[k][n] = 32 + (rand() % 64);
			if (B_mem_orig[k][n] > max_b)
				max_b = B_mem_orig[k][n];
			if (rand() & 1)
				B_mem_orig[k][n] = -B_mem_orig[k][n];
		}
}

static void init_sources()
{
	float q;
	float bias = 0.5;
	uint8_t max_a = 0;
	int8_t max_b = 0;

	memset(C_mem, 0, sizeof(C_mem));
       	memset(C_tmp_mem_in, 0, sizeof(C_tmp_mem_in));
       	memset(C_tmp_mem_out, 0, sizeof(C_tmp_mem_out));        

        init_a_and_b(max_a, max_b);
	q = 1.0 / (max_a * max_b);

	size_t i = 0;
	for (; i < 32; i++)
		q_bias[i] = q;
	for (; i < 64; i++)
		q_bias[i] = bias;

	for (size_t m = 0; m < M; m++)
		for (size_t n = 0; n < N; n++)
			for (size_t k = 0; k < K; k++)
				C_tmp_mem_in[m][n] +=
				    ((int32_t)A_mem[m][k]) *
				    ((int32_t)B_mem_orig[k][n]);

	for (size_t m = 0; m < M; m++)
		for (size_t n = 0; n < N; n++) {
			float v = static_cast<float>(C_tmp_mem_in[m][n]);
			v = v * q + bias;
			int32_t iv = static_cast<int32_t>(roundf(v));
			if (iv < 0)
				iv = 0;
			C_mem_expected[m][n] = iv > 255 ? 255 : iv;
		}

        init_a_and_b(max_a, max_b);
	for (size_t m = 0; m < M; m++)
		for (size_t n = 0; n < N; n++)
			for (size_t k = 0; k < K; k++)
				C_tmp_mem_out_expected[m][n] +=
				    ((int32_t)A_mem[m][k]) *
				    ((int32_t)B_mem_orig[k][n]);        
}

static void amx_ref_gemm_int8_uint8()
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
