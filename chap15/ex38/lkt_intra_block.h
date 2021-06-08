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

#ifndef KLT_INTRA_BLOCK_H__
#define KLT_INTRA_BLOCK_H__

// b0: input row vector from 4 consecutive 4x4 image block of word pixels
// rmc0-3: columnar vector coefficient of the RHS matrix, repeated 4X for
// 256-bit min32km1: saturation constant vector to cap intermediate pixel to
// less than or equal to 32767 w0: output row vector of garbled intermediate
// matrix, elements within each block are garbled e.g Low 128-bit of row 0 in
// descending order: y07, y05, y06, y04, y03, y01, y02, y00

#define __MYM_KIP_PXRMC_ROW_4X4WX4(b0, w0, rmc0_256, rmc1_256, rmc2_256,       \
				   rmc3_256, min32km1)                         \
	{                                                                      \
		__m256i tt0, tt1, tt2, tt3, tttmp;                             \
		tt0 = _mm256_madd_epi16(b0, (rmc0_256));                       \
		tt1 = _mm256_madd_epi16(b0, rmc1_256);                         \
		tt1 = _mm256_hadd_epi32(tt0, tt1);                             \
		tttmp = _mm256_srai_epi32(tt1, 31);                            \
		tttmp = _mm256_srli_epi32(tttmp, 25);                          \
		tt1 = _mm256_add_epi32(tt1, tttmp);                            \
		tt1 = _mm256_min_epi32(_mm256_srai_epi32(tt1, 7), min32km1);   \
		tt1 = _mm256_shuffle_epi32(tt1, 0xd8);                         \
		tt2 = _mm256_madd_epi16(b0, rmc2_256);                         \
		tt3 = _mm256_madd_epi16(b0, rmc3_256);                         \
		tt3 = _mm256_hadd_epi32(tt2, tt3);                             \
		tttmp = _mm256_srai_epi32(tt3, 31);                            \
		tttmp = _mm256_srli_epi32(tttmp, 25);                          \
		tt3 = _mm256_add_epi32(tt3, tttmp);                            \
		tt3 = _mm256_min_epi32(_mm256_srai_epi32(tt3, 7), min32km1);   \
		tt3 = _mm256_shuffle_epi32(tt3, 0xd8);                         \
		w0 = _mm256_blend_epi16(tt1, _mm256_slli_si256(tt3, 2), 0xaa); \
	}

// t0-t3: 256-bit input vectors of un-garbled intermediate matrix 1/128 * (B x
// R) lmr_256: 256-bit vector of one row of LHS coefficient, repeated 4X
// min32km1: saturation constant vector to cap final pixel to less than or equal
// to 32767 w0; Output row vector of final result in un-garbled order
#define __MYM_KIP_LMRXP_ROW_4X4WX4(w0, t0, t1, t2, t3, lmr_256, min32km1)      \
	{                                                                      \
		__m256i tb0, tb1, tb2, tb3, tbtmp;                             \
		tb0 = _mm256_madd_epi16(lmr_256, t0);                          \
		tb1 = _mm256_madd_epi16(lmr_256, t1);                          \
		tb1 = _mm256_hadd_epi32(tb0, tb1);                             \
		tbtmp = _mm256_srai_epi32(tb1, 31);                            \
		tbtmp = _mm256_srli_epi32(tbtmp, 25);                          \
		tb1 = _mm256_add_epi32(tb1, tbtmp);                            \
		tb1 = _mm256_min_epi32(_mm256_srai_epi32(tb1, 7), min32km1);   \
		tb1 = _mm256_shuffle_epi32(tb1, 0xd8);                         \
		tb2 = _mm256_madd_epi16(lmr_256, t2);                          \
		tb3 = _mm256_madd_epi16(lmr_256, t3);                          \
		tb3 = _mm256_hadd_epi32(tb2, tb3);                             \
		tbtmp = _mm256_srai_epi32(tb3, 31);                            \
		tbtmp = _mm256_srli_epi32(tbtmp, 25);                          \
		tb3 = _mm256_add_epi32(tb3, tbtmp);                            \
		tb3 = _mm256_min_epi32(_mm256_srai_epi32(tb3, 7), min32km1);   \
		tb3 = _mm256_shuffle_epi32(tb3, 0xd8);                         \
		tb3 = _mm256_slli_si256(tb3, 2);                               \
		tb3 = _mm256_blend_epi16(tb1, tb3, 0xaa);                      \
		w0 = _mm256_shuffle_epi8(                                      \
		    tb3, _mm256_setr_epi32(0x5040100, 0x7060302, 0xd0c0908,    \
					   0xf0e0b0a, 0x5040100, 0x7060302,    \
					   0xd0c0908, 0xf0e0b0a));             \
	}

#endif
