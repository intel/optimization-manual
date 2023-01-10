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

#include "fast_special_min.h"

#ifdef _MSC_VER
#ifndef _mm_storeu_ph
#define _mm_storeu_ph(x, a) _mm_storeu_ps((float *)(x), _mm_castph_ps(a))
#endif
#endif

void test_fast_special_min(const float *floats, uint16_t *halves,
			   uint16_t *mins)
{
	__m256 a = _mm256_load_ps(floats);
	__m128h ah = _mm_castsi128_ph(_mm256_cvtps_ph(a, 0));
	__m256 b = _mm256_load_ps(&floats[8]);
	__m128h bh = _mm_castsi128_ph(_mm256_cvtps_ph(b, 0));

	_mm_storeu_ph(halves, ah);
	_mm_storeu_ph(halves + 8, bh);
	__m128h res = fast_special_min(ah, bh);
	_mm_storeu_ph(mins, res);
}

// Assume the inputs are sane values, and are either both positive or opposite
// signs.
__m128h fast_special_min(__m128h lhs, __m128h rhs)
{
	const auto lhsInt16 = _mm_castph_si128(lhs);
	const auto rhsInt16 = _mm_castph_si128(rhs);
	const auto smallest = _mm_min_epi16(lhsInt16, rhsInt16);
	return _mm_castsi128_ph(smallest);
}
