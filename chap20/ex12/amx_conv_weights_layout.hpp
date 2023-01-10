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

#ifndef AMX_CONV_WEIGHTS_LAYOUT_HPP
#define AMX_CONV_WEIGHTS_LAYOUT_HPP

/*
  These types and macros are also defined in example 13

#define KH ...                           // Vertical dimension of the weights
#define KW ...                           // Horizontal dimension of the weights
#define KPACK (4/sizeof(type_t))         // Vertical K packing into Dword

type_t B_mem[KH][KW][K/KPACK][N][KPACK]; // Re-laid B matrices
*/

type_t B_mem_orig[K][N][KH][KW]; // Original weights

inline void amx_conv_weights_layout()
{
	for (int kh = 0; kh < KH; ++kh)
		for (int kw = 0; kw < KW; ++kw)
			for (int k = 0; k < K; ++k)
				for (int n = 0; n < N; ++n)
					B_mem[kh][kw][k / KPACK][n][k % KPACK] =
					    B_mem_orig[k][n][kh][kw];
}

#endif
