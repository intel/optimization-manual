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

#include "gtest/gtest.h"

#include "low_ofm_conv.hpp"
#include "optimisation_common.h"

const int NoInFMs = 64;
const int NoOutFMs = NUM_OFMS;
const int IFM_H = 1;
const int IFM_W = 16;

#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(64)) uint8_t inputs[IFM_W * IFM_H * NoInFMs];
__declspec(align(64)) float output[IFM_W * IFM_H * NoOutFMs];
__declspec(align(64)) int8_t weights[NoInFMs * NoOutFMs];
__declspec(align(64)) int8_t weights_reorged[64 * (NoInFMs / 4) * NoOutFMs];
__declspec(align(64)) uint8_t input_scalar[IFM_W * IFM_H * NoInFMs];
#else
uint8_t inputs[IFM_W * IFM_H * NoInFMs] __attribute__((aligned(64)));
float output[IFM_W * IFM_H * NoOutFMs] __attribute__((aligned(64)));
int8_t weights[NoInFMs * NoOutFMs] __attribute__((aligned(64)));
int8_t weights_reorged[64 * (NoInFMs / 4) * NoOutFMs]
    __attribute__((aligned(64)));
uint8_t input_scalar[IFM_W * IFM_H * NoInFMs] __attribute__((aligned(64)));
#endif

float dqfs[NoOutFMs] = {1.0, 1.0, 1.0};
float output_scalar[IFM_W * IFM_H * NoOutFMs];

void init_data()
{
	size_t offset = 0;
	for (size_t i = 0; i < IFM_H; i++) {
		for (size_t j = 0; j < IFM_W; j++) {
			for (size_t k = 0; k < NoInFMs; k++) {
				inputs[offset] = (uint8_t)offset;
				offset++;
			}
		}
	}

	offset = 0;
	for (size_t i = 0; i < NoInFMs; i++)
		for (size_t j = 0; j < NoOutFMs; j++) {
			weights[offset] = (int8_t)offset;
			offset++;
		}

	offset = 0;
	for (size_t j = 0; j < NoOutFMs; j++) {
		for (size_t i = 0; i < NoInFMs; i += 4) {
			size_t src_offset = j * NoInFMs + i;
			uint32_t *four = ((uint32_t *)&weights[src_offset]);
			for (size_t k = offset; k < offset + 64; k += 4)
				*((uint32_t *)&weights_reorged[k]) = *four;
			offset += 64;
		}
	}

	size_t base = 0;
	for (size_t i = 0; i < IFM_H; i++) {
		for (size_t k = 0; k < IFM_W; k++) {
			offset = k;
			for (size_t l = 0; l < NoInFMs / 16; l++) {
				for (size_t j = 0; j < 16; j++) {
					input_scalar[offset] =
					    (uint8_t)base + (uint8_t)j;
					offset += IFM_W;
				}
			}
			base += 16;
		}
	}

	for (size_t i = 0; i < NoOutFMs; i++)
		for (size_t j = 0; j < IFM_W; j++)
			for (size_t k = 0; k < NoInFMs; k++)
				output_scalar[i * IFM_W + j] +=
				    weights[i * NoInFMs + k] *
				    input_scalar[k * IFM_W + j];
}

TEST(vnni, low_ofm_conv)
{
	if (!supports_avx512_clx())
		GTEST_SKIP_("VNNI not supported, skipping test");

	init_data();

	low_ofm_conv(IFM_W, IFM_H, 16, NoInFMs, dqfs, inputs, output,
		     weights_reorged);

	for (int i = 0; i < NoOutFMs; i++)
		for (int j = 0; j < IFM_W; j++) {
			ASSERT_EQ(output[i * IFM_W + j],
				  output_scalar[i * IFM_W + j]);
		}
}
