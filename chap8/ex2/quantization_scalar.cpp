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

#include <algorithm>

#include <math.h>

#include "quantization_scalar.hpp"

void quantize_activations_scalar(const float *data, u8 *quantized_data,
				 int count, Dtype factor, int bits, int offset)
{
	int quant_min = 0;
	int quant_max = (1 << bits) - 1;
	//#pragma unroll (4)
	for (int i = 0; i < count; i++) {
		int int32_val = offset + (int)round(data[i] * factor);
		int32_val = std::max(std::min(int32_val, quant_max), quant_min);
		u8 quant_val = (u8)int32_val;
		quantized_data[i] = quant_val;
	}
}
