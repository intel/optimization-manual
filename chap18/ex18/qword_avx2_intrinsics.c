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

#include "qword_avx2.h"

void qword_avx2_intrinsics(const int64_t *a, const int64_t *b, int64_t *c,
			   uint64_t count)
{
	int N = (int)count;

	for (int i = 0; i < N; i += 32) {
		__m256i aa, bb, aah, bbh, mul, sum;
		//#pragma unroll(8)
		for (int j = 0; j < 8; j++) {
			aa = _mm256_loadu_si256(
			    (const __m256i *)(a + i + 4 * j));
			bb = _mm256_loadu_si256(
			    (const __m256i *)(b + i + 4 * j));
			sum = _mm256_add_epi64(aa, bb);
			mul = _mm256_mul_epu32(aa, bb);
			aah = _mm256_srli_epi64(aa, 32);
			bbh = _mm256_srli_epi64(bb, 32);
			aah = _mm256_mul_epu32(aah, bb);
			bbh = _mm256_mul_epu32(bbh, aa);
			aah = _mm256_add_epi32(aah, bbh);
			aah = _mm256_slli_epi64(aah, 32);
			mul = _mm256_add_epi64(mul, aah);
			aah = _mm256_cmpgt_epi64(mul, sum);
			aa = _mm256_castpd_si256(_mm256_blendv_pd(
			    _mm256_castsi256_pd(sum), _mm256_castsi256_pd(mul),
			    _mm256_castsi256_pd(aah)));
			_mm256_storeu_si256((__m256i *)(c + 4 * j), aa);
		}
		c += 32;
	}
}
