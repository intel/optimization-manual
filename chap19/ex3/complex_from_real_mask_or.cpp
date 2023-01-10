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

#include "complex_from_real_mask_or.h"

unsigned int get_complex_mask_from_real_mask_or(unsigned int m)
{
	__mmask8 res = getComplexMaskFromRealMask_OR(_cvtu32_mask8(m));
	return _cvtmask8_u32(res);
}

__mmask8 getComplexMaskFromRealMask_OR(__mmask8 m)
{
	auto wholeElements = _mm_movm_epi16(m);

	// Similar logic to the AND variant above but now any 32-bit element
	// which isn't zero represents the logical OR or two adjacent 16-bit
	// block elements in one 32-bit block.

	return _mm_cmp_epi32_mask(wholeElements, __m128i(), _MM_CMPINT_NE);
}
