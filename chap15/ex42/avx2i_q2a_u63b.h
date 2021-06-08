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

#ifndef AVX2_Q2A_U63B_H__
#define AVX2_Q2A_U63B_H__

unsigned int avx2i_q2a_u63b(uint64_t xx, char *ps)
{
	__m128i v0;
	__m256i m0, x1, x3, x4, x5;
	unsigned long long xxi, xx2, lo64, hi64;
	int64_t w;
	int j, cnt, abv16, tmp, idx, u;
	// conversion of less than 4 digits
	if (xx < 10000) {
		j = ubs_avx2_lt10k_2s_i2((unsigned int)xx, ps);
		return j;
	} else if (xx <
		   100000000) { // dynamic range of xx is less than 9 digits
		// conversion of 5-8 digits
		x1 = _mm256_broadcastd_epi32(
		    _mm_cvtsi32_si128((int)xx)); // broadcast to every dword
		// calculate quotient and remainder, each with reduced range (<
		// 10^4)
		x3 = _mm256_mul_epu32(
		    x1, _mm256_loadu_si256((__m256i *)pr_cg_10to4));
		x3 = _mm256_mullo_epi32(
		    _mm256_srli_epi64(x3, 40),
		    _mm256_loadu_si256((__m256i *)pr_1_m10to4));
		// quotient in dw4, remainder in dw0
		m0 = _mm256_add_epi32(
		    _mm256_inserti128_si256(_mm256_setzero_si256(),
					    _mm_cvtsi32_si128((int)xx), 0),
		    x3);
		__PARMOD10TO4AVX2DW4_0(x3,
				       m0); // 8 digit in low byte of each dw
		x3 = _mm256_add_epi32(x3, _mm256_set1_epi32(0x30303030));
		x4 = _mm256_shuffle_epi8(
		    x3, _mm256_setr_epi32(0x0004080c, 0x80808080, 0x80808080,
					  0x80808080, 0x0004080c, 0x80808080,
					  0x80808080, 0x80808080));
		// pack 8 single-digit integer into first 8 bytes and set rest
		// to zeros
		x4 = _mm256_permutevar8x32_epi32(
		    x4,
		    _mm256_setr_epi32(0x4, 0x0, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1));
		tmp = _mm256_movemask_epi8(
		    _mm256_cmpgt_epi8(x4, _mm256_set1_epi32(0x30303030)));
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
		_BitScanForward(&idx, tmp);
#else
		idx = _bit_scan_forward(tmp);
#endif
		cnt = 8 - idx; // actual number non-zero-leading digits to write
			       // to output
	} else {	       // conversion of 9-12 digits
		lo64 = _mulx_u64(xx, (uint64_t)QWCG10to8, &hi64);
		hi64 >>= 26;
		xxi = _mulx_u64(hi64, (uint64_t)100000000, &xx2);
		lo64 = (uint64_t)xx - xxi;
		if (hi64 < 10000) { // do digist 12-9 first
			__PARMOD10TO4AVX2DW(v0, (int)hi64);
			v0 = _mm_add_epi32(v0, _mm_set1_epi32(0x30303030));
			// continue conversion of low 8 digits of a less-than
			// 12-digit value
			x5 = _mm256_inserti128_si256(
			    _mm256_setzero_si256(),
			    _mm_cvtsi32_si128((int)lo64), 0);
			x1 = _mm256_broadcastd_epi32(_mm_cvtsi32_si128(
			    (int)lo64)); // broadcast to every dword
			x3 = _mm256_mul_epu32(
			    x1, _mm256_loadu_si256((__m256i *)pr_cg_10to4));
			x3 = _mm256_mullo_epi32(
			    _mm256_srli_epi64(x3, 40),
			    _mm256_loadu_si256((__m256i *)pr_1_m10to4));
			m0 = _mm256_add_epi32(
			    x5, x3); // quotient in dw4, remainder in dw0
			__PARMOD10TO4AVX2DW4_0(x3, m0);
			x3 =
			    _mm256_add_epi32(x3, _mm256_set1_epi32(0x30303030));
			x4 = _mm256_shuffle_epi8(
			    x3, _mm256_setr_epi32(0x0004080c, 0x80808080,
						  0x80808080, 0x80808080,
						  0x0004080c, 0x80808080,
						  0x80808080, 0x80808080));
			x5 = _mm256_inserti128_si256(
			    _mm256_setzero_si256(),
			    _mm_shuffle_epi8(
				v0, _mm_setr_epi32(0x80808080, 0x80808080,
						   0x0004080c, 0x80808080)),
			    0);
			x4 = _mm256_permutevar8x32_epi32(
			    _mm256_or_si256(x4, x5),
			    _mm256_setr_epi32(0x2, 0x4, 0x0, 0x1, 0x1, 0x1, 0x1,
					      0x1));
			tmp = _mm256_movemask_epi8(_mm256_cmpgt_epi8(
			    x4, _mm256_set1_epi32(0x30303030)));
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
			_BitScanForward(&idx, tmp);
#else
			idx = _bit_scan_forward(tmp);
#endif
			cnt = 12 - idx;
		} else { // handle greater than 12 digit input value
			cnt = 0;
			if (hi64 > 100000000) { // case of input value has more
						// than 16 digits
				xxi =
				    _mulx_u64(hi64, (uint64_t)QWCG10to8, &xx2);
				abv16 = (int)(xx2 >> 26);
				hi64 -= _mulx_u64((uint64_t)abv16,
						  (uint64_t)100000000, &xx2);
				__PARMOD10TO4AVX2DW(v0, abv16);
				v0 = _mm_add_epi32(v0,
						   _mm_set1_epi32(0x30303030));
				v0 = _mm_shuffle_epi8(
				    v0, _mm_setr_epi32(0x0004080c, 0x80808080,
						       0x80808080, 0x80808080));
				tmp = _mm_movemask_epi8(_mm_cmpgt_epi8(
				    v0, _mm_set1_epi32(0x30303030)));
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
				_BitScanForward(&idx, tmp);
#else
				idx = _bit_scan_forward(tmp);
#endif
				cnt = 4 - idx;
			}

			// conversion of lower 16 digits
			x1 = _mm256_broadcastd_epi32(_mm_cvtsi32_si128(
			    (int)hi64)); // broadcast to every dword
			x3 = _mm256_mul_epu32(
			    x1, _mm256_loadu_si256((__m256i *)pr_cg_10to4));
			x3 = _mm256_mullo_epi32(
			    _mm256_srli_epi64(x3, 40),
			    _mm256_loadu_si256((__m256i *)pr_1_m10to4));
			m0 = _mm256_add_epi32(_mm256_inserti128_si256(
						  _mm256_setzero_si256(),
						  _mm_cvtsi32_si128((int)hi64),
						  0),
					      x3);
			__PARMOD10TO4AVX2DW4_0(x3, m0);
			x3 =
			    _mm256_add_epi32(x3, _mm256_set1_epi32(0x30303030));
			x4 = _mm256_shuffle_epi8(
			    x3, _mm256_setr_epi32(0x0004080c, 0x80808080,
						  0x80808080, 0x80808080,
						  0x0004080c, 0x80808080,
						  0x80808080, 0x80808080));
			x1 = _mm256_broadcastd_epi32(_mm_cvtsi32_si128(
			    (int)lo64)); // broadcast to every dword
			x3 = _mm256_mul_epu32(
			    x1, _mm256_loadu_si256((__m256i *)pr_cg_10to4));
			x3 = _mm256_mullo_epi32(
			    _mm256_srli_epi64(x3, 40),
			    _mm256_loadu_si256((__m256i *)pr_1_m10to4));
			m0 = _mm256_add_epi32(_mm256_inserti128_si256(
						  _mm256_setzero_si256(),
						  _mm_cvtsi32_si128((int)lo64),
						  0),
					      x3);
			__PARMOD10TO4AVX2DW4_0(x3, m0);
			x3 =
			    _mm256_add_epi32(x3, _mm256_set1_epi32(0x30303030));
			x5 = _mm256_shuffle_epi8(
			    x3, _mm256_setr_epi32(0x80808080, 0x80808080,
						  0x0004080c, 0x80808080,
						  0x80808080, 0x80808080,
						  0x0004080c, 0x80808080));
			x4 = _mm256_permutevar8x32_epi32(
			    _mm256_or_si256(x4, x5),
			    _mm256_setr_epi32(0x4, 0x0, 0x6, 0x2, 0x1, 0x1, 0x1,
					      0x1));
			cnt += 16;
			if (cnt <= 16) {
				tmp = _mm256_movemask_epi8(_mm256_cmpgt_epi8(
				    x4, _mm256_set1_epi32(0x30303030)));
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
				_BitScanForward(&idx, tmp);
#else
				idx = _bit_scan_forward(tmp);
#endif
				cnt -= idx;
			}
		}
	}
	w = _mm_cvtsi128_si64(_mm256_castsi256_si128(x4));
	switch (cnt) {
	case 5:
		*ps++ = (char)(w >> 24);
		*(unsigned int *)ps = (w >> 32);
		break;
	case 6:
		*(short *)ps = (short)(w >> 16);
		*(unsigned int *)(&ps[2]) = (w >> 32);
		break;
	case 7:
		*ps = (char)(w >> 8);
		*(short *)(&ps[1]) = (short)(w >> 16);
		*(unsigned int *)(&ps[3]) = (w >> 32);
		break;
	case 8:
		*(long long *)ps = w;
		break;
	case 9:
		*ps++ = (char)(w >> 24);
		*(long long *)(&ps[0]) = _mm_cvtsi128_si64(
		    _mm_srli_si128(_mm256_castsi256_si128(x4), 4));
		break;
	case 10:
		*(short *)ps = (short)(w >> 16);
		*(long long *)(&ps[2]) = _mm_cvtsi128_si64(
		    _mm_srli_si128(_mm256_castsi256_si128(x4), 4));
		break;
	case 11:
		*ps = (char)(w >> 8);
		*(short *)(&ps[1]) = (short)(w >> 16);
		*(long long *)(&ps[3]) = _mm_cvtsi128_si64(
		    _mm_srli_si128(_mm256_castsi256_si128(x4), 4));
		break;
	case 12:
		*(unsigned int *)ps = (unsigned int)w;
		*(long long *)(&ps[4]) = _mm_cvtsi128_si64(
		    _mm_srli_si128(_mm256_castsi256_si128(x4), 4));
		break;
	case 13:
		*ps++ = (char)(w >> 24);
		*(unsigned int *)ps = (w >> 32);
		*(long long *)(&ps[4]) = _mm_cvtsi128_si64(
		    _mm_srli_si128(_mm256_castsi256_si128(x4), 8));
		break;
	case 14:
		*(short *)ps = (short)(w >> 16);
		*(unsigned int *)(&ps[2]) = (w >> 32);
		*(long long *)(&ps[6]) = _mm_cvtsi128_si64(
		    _mm_srli_si128(_mm256_castsi256_si128(x4), 8));
		break;
	case 15:
		*ps = (char)(w >> 8);
		*(short *)(&ps[1]) = (short)(w >> 16);
		*(unsigned int *)(&ps[3]) = (w >> 32);
		*(long long *)(&ps[7]) = _mm_cvtsi128_si64(
		    _mm_srli_si128(_mm256_castsi256_si128(x4), 8));
		break;
	case 16:
		_mm_storeu_si128((__m128i *)ps, _mm256_castsi256_si128(x4));
		break;
	case 17:
		u = (int)_mm_cvtsi128_si64(v0);
		*ps++ = (char)(u >> 24);
		_mm_storeu_si128((__m128i *)&ps[0], _mm256_castsi256_si128(x4));
		break;
	case 18:
		u = (int)_mm_cvtsi128_si64(v0);
		*(short *)ps = (short)(u >> 16);
		_mm_storeu_si128((__m128i *)&ps[2], _mm256_castsi256_si128(x4));
		break;
	case 19:
		u = (int)_mm_cvtsi128_si64(v0);
		*ps = (char)(u >> 8);
		*(short *)(&ps[1]) = (short)(u >> 16);
		_mm_storeu_si128((__m128i *)&ps[3], _mm256_castsi256_si128(x4));
		break;
	case 20:
		u = (int)_mm_cvtsi128_si64(v0);
		*(unsigned int *)ps = (short)(u);
		_mm_storeu_si128((__m128i *)&ps[4], _mm256_castsi256_si128(x4));
		break;
	}
	return cnt;
}

#endif
