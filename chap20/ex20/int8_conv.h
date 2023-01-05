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

#ifndef INT8_CONV_H
#define INT8_CONV_H

#include <immintrin.h>

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

const int32_t db_sel[16] = {0, 4, 8,  12, 1, 5, 9,  13,
			    2, 6, 10, 14, 3, 7, 11, 15};

inline __m512i Pack_DwordsToBytes(__m512i dwords[4])
{
	const __m512i sel_reg = _mm512_load_si512(db_sel);
	const __m512i word_0 = _mm512_packs_epi32(dwords[0], dwords[1]);
	const __m512i word_1 = _mm512_packs_epi32(dwords[2], dwords[3]);
	__m512i bytes = _mm512_packus_epi16(word_0, word_1);

	bytes = _mm512_permutexvar_epi32(sel_reg, bytes);

	return bytes;
}

#ifdef __cplusplus
}
#endif

#endif
