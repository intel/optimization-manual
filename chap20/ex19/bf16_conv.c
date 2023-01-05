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

#include <immintrin.h>

#include "bf16_conv.h"

void bf16_conv(float *spad, bfloat_16 *next_inputs,
	       unsigned int (*inputs_spatial_dim)(void))
{
	for (int i = 0; i < 16; i++) {
		__m512 f32_0 = _mm512_load_ps(spad);
		__m512 f32_1 = _mm512_load_ps(spad + 16 * 16);
		__m512 bf16 =
		    _mm512_castsi512_ps(_mm512_cvtne2ps_pbh(f32_1, f32_0));
		_mm512_store_ps(next_inputs, bf16);

		spad += 16; /* Next TILE row */
		next_inputs += 32 * inputs_spatial_dim();
	}
}

bool bf16_conv_check(float *spad, bfloat_16 *next_inputs,
		     unsigned int (*inputs_spatial_dim)(void))
{
	/*
	 * spad is expected to be a buffer of 2k in length.
	 * next_inputs is expected to be (15 * 64 * inputs_spatial_dim()) + 64
	 */

	if (!spad || !next_inputs || !inputs_spatial_dim)
		return false;

	/*
	 * inputs_spatial_dim is expected to return an number > 0
	 */

	if (inputs_spatial_dim() == 0)
		return false;

	bf16_conv(spad, next_inputs, inputs_spatial_dim);

	return true;
}
