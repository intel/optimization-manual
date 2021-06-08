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

#include "low_ofm_conv.hpp"
#include <stdio.h>

void low_ofm_conv(int IFM_W, int IFM_H, int IFMBlock, int NUM_IFMS, float *dqfs,
		  const uint8_t *input, float *output, int8_t *weights_reorged)
{
	/*
	# IFM_W % 16 == 0
	# NUM_OFMS = 3
	# NUM_IFMS = 64
	# dqfs - array of dequantization factors for the down convert
	*/
	int src_ifm_size = IFM_H * IFM_W * IFMBlock;
	int ofm_size = IFM_W * IFM_H;

	__m512i gather_indices = _mm512_setr_epi32(
	    0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60);

	__m512 dqf_broadcast[NUM_OFMS];

	for (int ofm = 0; ofm < NUM_OFMS; ofm++) {
		dqf_broadcast[ofm] = _mm512_set1_ps(dqfs[ofm]);
	}

	for (int h = 0; h < IFM_H; h++) {
		int src_line_offset = h * IFM_W * IFMBlock;
		int w = 0;
		int src_w_offset = src_line_offset;
		for (; w < IFM_W; w += 16) {
			__m512i res_i32[NUM_OFMS] = {0};

			// Convolve 4x16 OFMs by reorganizing on the fly.
			for (int ifm = 0; ifm < NUM_IFMS; ifm += 4) {
				int src_block_offset = ifm & 0xf;
				int src_ifm_index = ifm >> 4;
				size_t src_ifm_offset =
				    src_w_offset +
				    src_ifm_index * src_ifm_size +
				    src_block_offset;
				__m512i ivec = _mm512_i32gather_epi32(
				    gather_indices, input + src_ifm_offset, 4);

				for (int ofm = 0; ofm < NUM_OFMS; ofm++) {
					int weight_offset =
					    (ofm * NUM_IFMS + ifm) * 16;
					__m512i wvec = _mm512_load_si512(
					    weights_reorged + weight_offset);
					res_i32[ofm] = _mm512_dpbusd_epi32(
					    res_i32[ofm], ivec, wvec);
				}
			}
			// Down convert and store results in native layout.
			// #pragma unroll(NUM_OFMS)
			for (int ofm = 0; ofm < NUM_OFMS; ofm++) {
				__m512 res_f32 =
				    _mm512_cvtepi32_ps(res_i32[ofm]);
				res_f32 =
				    _mm512_mul_ps(res_f32, dqf_broadcast[ofm]);
				size_t output_offset =
				    ofm * ofm_size + h * IFM_W + w;
				_mm512_store_ps(output + output_offset,
						res_f32);
			}
			src_w_offset += 16 * IFMBlock;
		}
	}
}
