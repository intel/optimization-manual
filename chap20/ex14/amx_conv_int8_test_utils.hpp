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

#ifndef AMX_CONV_INT8_TEST_UTILS_HPP
#define AMX_CONV_INT8_TEST_UTILS_HPP

#define C K

#include "../ex11/amx_conv_activations_layout.hpp"
#include "../ex12/amx_conv_weights_layout.hpp"

res_type_t C_mem_expected[N][HC*WC];

static int8_t next_int8(int8_t i)
{
	if (i == 127)
		return -128;
	return i + 1;
}

static void init_sources()
{
        type_t A_mem_scalar[KH*KW*C][HC*WC];
        type_t B_mem_scalar[N][KH*KW*C];
	int8_t counter = -128;

	memset(C_mem, 0, sizeof(C_mem));

        for (size_t c = 0; c < C; c++)
                for (size_t h = 0; h < H; h++)
                        for (size_t w = 0; w < W; w++) {
                                A_mem_orig[c][h][w] = counter;
                                counter = next_int8(counter);
                                counter = (rand() % 256) - 128;
                        }

	for (size_t k = 0; k < K; k++)
		for (size_t n = 0; n < N; n++)
                        for (size_t kh = 0; kh < KH; kh++)
                                for (size_t kw = 0; kw < KW; kw++) {
                                        B_mem_orig[k][n][kh][kw] = (counter % 32) - 16;
                                        counter = next_int8(counter);
                                }

        /*
         * Re-layout A_mem.
         */

        amx_conv_activations_layout();

        /*
         * Re-layout B_mem.
         */

        amx_conv_weights_layout();
        
        /* Need to re-layout A_mem for scalar computation. */

        size_t col = 0;
	for (size_t hc = 0; hc < HC; hc++) {
		for (size_t wc = 0; wc < WC; wc++) {
                        size_t row = 0;
                        for (size_t c = 0; c < C; c++)
                                for (size_t kh = 0; kh < KH; kh++)
                                        for (size_t kw = 0; kw < KW; kw++) {
                                                A_mem_scalar[row][col] =
                                                        A_mem_orig[c][hc+kh][wc+kw];
                                                row++;
                                        }
                        col++;
                }
        }

        /* Need to re-layout B_mem for scalar computation. */

        for (size_t n = 0; n < N; n++) {
                col = 0;
                for (size_t k = 0; k < K; k++)
                        for (size_t kh = 0; kh < KH; kh++)
                                for (size_t kw = 0; kw < KW; kw++) {
                                        B_mem_scalar[n][col] = B_mem_orig[k][n][kh][kw];
                                        col++;
                                }
        }

        /* Let's do the matmul. */

	for (size_t m = 0; m < N; m++)
		for (size_t n = 0; n < HC*WC; n++)
			for (size_t k = 0; k < KH*KW*C; k++)
				C_mem_expected[m][n] +=
                                        ((int32_t) B_mem_scalar[m][k]) * ((int32_t)A_mem_scalar[k][n]);
}

#endif
