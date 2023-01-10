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
#include <stdint.h>
#include <string.h>

#include "embedding.h"

void prefetched_embedding(uint32_t *a, float *e, float *c, size_t num_indices,
			  float scale, float bias, size_t lookahead)
{
	__m512 s = _mm512_set1_ps(scale);
	__m512 b = _mm512_set1_ps(bias);

	for (size_t i = 0; i < num_indices; i++) {
		_mm_prefetch(
		    (char const *)&e[a[i + lookahead] * FLOATS_PER_CACHE_LINE],
		    _MM_HINT_T0);
		__m512 ereg =
		    _mm512_load_ps(&e[((size_t)a[i]) * FLOATS_PER_CACHE_LINE]);
		__m512 creg = _mm512_fmadd_ps(ereg, s, b);

		_mm512_store_ps(&c[i * FLOATS_PER_CACHE_LINE], creg);
	}
}

bool prefetched_embedding_check(uint32_t *a, float *e, float *c,
				size_t num_indices, float scale, float bias,
				size_t lookahead)
{
	/*
	 * a, e and c must be non-NULL.
	 * e and c must be 64 byte aligned.
	 * a must have num_indices + lookahead elements
	 */

	if (!a || !e || !c)
		return false;

	if (((uintptr_t)e) % 64 != 0)
		return false;

	if (((uintptr_t)c) % 64 != 0)
		return false;

	prefetched_embedding(a, e, c, num_indices, scale, bias, lookahead);

	return true;
}

void noprefetched_embedding(uint32_t *a, float *e, float *c, size_t num_indices,
			    float scale, float bias)
{
	__m512 s = _mm512_set1_ps(scale);
	__m512 b = _mm512_set1_ps(bias);

	for (size_t i = 0; i < num_indices; i++) {
		__m512 ereg =
		    _mm512_load_ps(&e[((size_t)a[i]) * FLOATS_PER_CACHE_LINE]);
		__m512 creg = _mm512_fmadd_ps(ereg, s, b);

		_mm512_store_ps(&c[i * FLOATS_PER_CACHE_LINE], creg);
	}
}
