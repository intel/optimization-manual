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

#ifndef UBSAVX2_H_
#define UBSAVX2_H_

#include <immintrin.h>
#include <parmod10.h>

// Convert unsigned short (< 10^4) to ascii
static inline int ubs_avx2_lt10k_2s_i2(int x_lt10k, char *ps)
{
	int tmp;
	__m128i x0, m0, x2, x3, x4;

	if (x_lt10k < 10) {
		*ps = '0' + x_lt10k;
		return 1;
	}
	x0 = _mm_broadcastd_epi32(_mm_cvtsi32_si128(x_lt10k));
	// calculate quotients of divisors 10, 100, 1000, 10000
	m0 = _mm_loadu_si128((__m128i *)quo_ten_thsn_mulplr_d);
	x2 = _mm_mulhi_epu16(x0, m0);
	// u16/10, u16/100, u16/1000, u16/10000
	x2 = _mm_srlv_epi32(x2, _mm_setr_epi32(0x0, 0x4, 0x7, 0xa));
	// 0, u16, 0, u16/10, 0, u16/100, 0, u16/1000
	x3 = _mm_insert_epi16(_mm_slli_si128(x2, 6), (int)x_lt10k, 1);
	x4 = _mm_or_si128(x2, x3);
	// produce 4 single digits in low byte of each dword
	x4 = _mm_madd_epi16(
	    x4, _mm_loadu_si128(
		    (__m128i *)mten_mulplr_d)); // add bias for ascii encoding
	x2 = _mm_add_epi32(x4, _mm_set1_epi32(0x30303030));
	// pack 4 single digit into a dword, start with most significant digit
	x3 = _mm_shuffle_epi8(
	    x2, _mm_setr_epi32(0x0004080c, 0x80808080, 0x80808080, 0x80808080));
	if (x_lt10k > 999) {
		*(int *)ps = _mm_cvtsi128_si32(x3);
		return 4;
	}

	tmp = _mm_cvtsi128_si32(x3);
	if (x_lt10k > 99) {
		*((short *)(ps)) = (short)(tmp >> 8);
		ps[2] = (char)(tmp >> 24);
		return 3;
	}
	*((short *)ps) = (short)(tmp >> 16);
	return 2;
}

#endif
