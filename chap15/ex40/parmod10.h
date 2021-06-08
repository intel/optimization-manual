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

#ifndef PARMOD10_H__
#define PARMOD10_H__

static short quo_ten_thsn_mulplr_d[16] = {0x199a, 0, 0x28f6, 0, 0x20c5, 0,
					  0x1a37, 0, 0x199a, 0, 0x28f6, 0,
					  0x20c5, 0, 0x1a37, 0};
static short mten_mulplr_d[16] = {-10, 1, -10, 1, -10, 1, -10, 1,
				  -10, 1, -10, 1, -10, 1, -10, 1};

// macro to convert input t5 (a __m256i type) containing quotient (dword 4) and
// remainder (dword 0) into single-digit integer (between 0-9) in output y3 (
// a__m256i);
// both dword element "t5" is assume to be less than 10^4, the rest of dword
// must be 0; the output is 8 single-digit integer, located in the low byte of
// each dword, MS digit in dword 0
#define __PARMOD10TO4AVX2DW4_0(y3, t5)                                         \
	{                                                                      \
		__m256i x0, x2;                                                \
		x0 = _mm256_shuffle_epi32(t5, 0);                              \
		x2 = _mm256_mulhi_epu16(                                       \
		    x0, _mm256_loadu_si256((__m256i *)quo_ten_thsn_mulplr_d)); \
		x2 = _mm256_srlv_epi32(x2,                                     \
				       _mm256_setr_epi32(0x0, 0x4, 0x7, 0xa,   \
							 0x0, 0x4, 0x7, 0xa)); \
		(y3) = _mm256_or_si256(_mm256_slli_si256(x2, 6),               \
				       _mm256_slli_si256(t5, 2));              \
		(y3) = _mm256_or_si256(x2, y3);                                \
		(y3) = _mm256_madd_epi16(                                      \
		    y3, _mm256_loadu_si256((__m256i *)mten_mulplr_d));         \
	}
// parallel conversion of dword integer (< 10^4) to 4 single digit integer in
// __m128i
#define __PARMOD10TO4AVX2DW(x3, dw32)                                          \
	{                                                                      \
		__m128i x0, x2;                                                \
		x0 = _mm_broadcastd_epi32(_mm_cvtsi32_si128(dw32));            \
		x2 = _mm_mulhi_epu16(                                          \
		    x0, _mm_loadu_si128((__m128i *)quo_ten_thsn_mulplr_d));    \
		x2 = _mm_srlv_epi32(x2, _mm_setr_epi32(0x0, 0x4, 0x7, 0xa));   \
		(x3) =                                                         \
		    _mm_or_si128(_mm_slli_si128(x2, 6),                        \
				 _mm_slli_si128(_mm_cvtsi32_si128(dw32), 2));  \
		(x3) = _mm_or_si128(x2, (x3));                                 \
		(x3) = _mm_madd_epi16(                                         \
		    (x3), _mm_loadu_si128((__m128i *)mten_mulplr_d));          \
	}

#endif
