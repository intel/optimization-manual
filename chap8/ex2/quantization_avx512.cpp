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

#include <immintrin.h>

#include "quantization_avx512.hpp"

#define ALIGN(a, b) (((a) / (b)) * (b))
#define INTR_VECTOR_LENGTH_32_bit (512 / 32)

void quantize_activations_avx512(const float *data, u8 *quantized_data,
				 int count, Dtype factor, int bits, int offset)
{
	int quant_min = 0;
	int quant_max = (1 << bits) - 1;
	int count_aligned = ALIGN(count, INTR_VECTOR_LENGTH_32_bit);
	__m512i offset_broadcast = _mm512_set1_epi32(offset);
	__m512 factor_broadcast = _mm512_set1_ps(factor);
	__m512i quant_min_broadcast = _mm512_set1_epi32(quant_min);
	__m512i quant_max_broadcast = _mm512_set1_epi32(quant_max);
	// #pragma unroll (4)
	for (int i = 0; i < count_aligned; i += INTR_VECTOR_LENGTH_32_bit) {
		__m512 data_m512 = _mm512_load_ps(&data[i]);
		data_m512 = _mm512_mul_ps(data_m512, factor_broadcast);
		__m512i data_i32 = _mm512_cvt_roundps_epi32(
		    data_m512, _MM_FROUND_TO_NEAREST_INT | _MM_FROUND_NO_EXC);
		data_i32 = _mm512_add_epi32(data_i32, offset_broadcast);
		data_i32 = _mm512_max_epi32(data_i32, quant_min_broadcast);
		data_i32 = _mm512_min_epi32(data_i32, quant_max_broadcast);
		__m128i q = _mm512_cvtusepi32_epi8(data_i32);
		_mm_store_si128((__m128i *)(&quantized_data[i]), q);
	}
}
