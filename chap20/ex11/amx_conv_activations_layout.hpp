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

#ifndef AMX_CONV_ACTIVATIONS_LAYOUT_HPP
#define AMX_CONV_ACTIVATIONS_LAYOUT_HPP

/*
  These types and macros are also defined in example 13

#define K C                         // K-dimension of the A matrix = channels
#define M H*W                       // M-dimension of the A matrix = spatial
type_t A_mem[H][W][K];               // Re-laid A matrix
*/

type_t A_mem_orig[C][H][W]; // Original activations tensor

inline void amx_conv_activations_layout()
{
	for (int c = 0; c < C; ++c)
		for (int h = 0; h < H; ++h)
			for (int w = 0; w < W; ++w)
				A_mem[h][w][c] = A_mem_orig[c][h][w];
}

#endif
