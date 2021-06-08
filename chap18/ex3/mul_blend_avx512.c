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

#include "mul_blend_avx512.h"

void mul_blend_avx512(double *a, double *b, double *c, size_t N)
{
	for (int i = 0; i < N; i += 32) {
		__m512d aa, bb;
		__mmask8 mask;
		//#pragma unroll(4)
		for (int j = 0; j < 4; j++) {
			aa = _mm512_loadu_pd(a + i + j * 8);
			bb = _mm512_loadu_pd(b + i + j * 8);
			mask = _mm512_cmp_pd_mask(_mm512_set1_pd(1.0), aa, 1);
			bb = _mm512_mask_mul_pd(bb, mask, aa, bb);
			_mm512_storeu_pd(c + 8 * j, bb);
		}
		c += 32;
	}
}

bool mul_blend_avx512_check(double *a, double *b, double *c, size_t N)
{
	/*
	 * a, b and c must be non-NULL.
	 */

	if (!a || !b || !c)
		return false;

	/*
	 * N must be a multiple of 32.
	 */

	if (N % 32 != 0)
		return false;

	mul_blend_avx512(a, b, c, N);

	return true;
}
