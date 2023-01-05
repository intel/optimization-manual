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

#include "compress_ph.h"

#ifdef _MSC_VER
#ifndef _mm512_storeu_ph
#define _mm512_storeu_ph(x, a)                                                 \
	_mm512_storeu_ps((void *)(x), _mm512_castph_ps(a))
#endif
#endif

void test_compress_ph(uint32_t mask, const float *floats, uint16_t *halves,
		      uint16_t *compressed_halves)
{
	__m512 a = _mm512_load_ps(floats);
	__m512 b = _mm512_load_ps(&floats[16]);
	__m512i ah =
	    _mm512_castsi256_si512(_mm512_cvtps_ph(a, _MM_FROUND_NO_EXC));
	__m256i bh = _mm512_cvtps_ph(b, _MM_FROUND_NO_EXC);
	__m512i merged = _mm512_inserti64x4(ah, bh, 1);
	__m512h merged_h = _mm512_castsi512_ph(merged);
	__m512h res = compress_ph(__m512h(), _load_mask32(&mask), merged_h);

	_mm512_storeu_ph(halves, merged_h);
	_mm512_storeu_ph(compressed_halves, res);
}

__m512h compress_ph(__m512h src, __mmask32 mask, __m512h value)
{
	const auto asInt16 = _mm512_castph_si512(value);
	const auto src16 = _mm512_castph_si512(src);
	const auto comp = _mm512_mask_compress_epi16(src16, mask, asInt16);
	return _mm512_castsi512_ph(comp);
}
