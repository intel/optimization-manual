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

#include <assert.h>
#include <cstddef>
#include <stdint.h>

#include "pixel_shuffler.hpp"

void pixel_shuffler(const vector<int> &bottom_shape,
		    const vector<int> &top_shape, const pstype *bottom_data,
		    pstype *top_data)
{
	const int N = bottom_shape[0];
	assert(N == top_shape[0]);
	const int bc = bottom_shape[1];
	const int bh = bottom_shape[2];
	const int bw = bottom_shape[3];
	const int tc = top_shape[1];
	const int th = top_shape[2];
	const int tw = top_shape[3];
	const int r = th / bh;
	int bottom_ch_size = bw * bh;
	int top_ch_size = tw * th;
	pstype *cur_channel = NULL;
	for (int n = 0; n < N; n++) {
		const pstype *src = bottom_data + n * bc * bottom_ch_size;
		pstype *dst = top_data + n * tc * top_ch_size;
		for (int c = 0; c < tc; c++) {
			cur_channel = dst + c * top_ch_size;
			for (int h = 0; h < bh; h++) {
				for (int w = 0; w < bw; w++) {
					int bottom_offset = h * bw + w;
					int bottom_index =
					    c * bottom_ch_size + bottom_offset;
					int top_index = h * r * tw + w * r;
					cur_channel[top_index] =
					    src[bottom_index]; // top left
					bottom_index =
					    (c + tc) * bottom_ch_size +
					    bottom_offset;
					top_index = h * r * tw + w * r + 1;
					cur_channel[top_index] =
					    src[bottom_index]; // top right
					bottom_index =
					    (c + 2 * tc) * bottom_ch_size +
					    bottom_offset;
					top_index = (h * r + 1) * tw + w * r;
					cur_channel[top_index] =
					    src[bottom_index]; // bottom left
					bottom_index =
					    (c + 3 * tc) * bottom_ch_size +
					    bottom_offset;
					top_index =
					    (h * r + 1) * tw + w * r + 1;
					cur_channel[top_index] =
					    src[bottom_index]; // bottom right
				}
			}
		}
	}
}
