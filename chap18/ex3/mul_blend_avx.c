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

#include "mul_blend_avx.h"

void mul_blend_avx(double *a, double *b, double *c, size_t N)
{
	for (int i = 0; i < N; i += 32) {
		__m256d aa, bb, mask;
		// #pragma unroll(8)
		for (int j = 0; j < 8; j++) {
			aa = _mm256_loadu_pd(a + i + j * 4);
			bb = _mm256_loadu_pd(b + i + j * 4);
			mask = _mm256_cmp_pd(_mm256_set1_pd(1.0), aa, 1);
			aa = _mm256_and_pd(aa, mask); // zero the false values
			aa = _mm256_mul_pd(aa, bb);
			bb = _mm256_blendv_pd(bb, aa, mask);
			_mm256_storeu_pd(c + 4 * j, bb);
		}
		c += 32;
	}
}

bool mul_blend_avx_check(double *a, double *b, double *c, size_t N)
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

	mul_blend_avx(a, b, c, N);

	return true;
}
