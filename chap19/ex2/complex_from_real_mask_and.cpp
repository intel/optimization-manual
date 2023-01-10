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

#include "complex_from_real_mask_and.h"

unsigned int get_complex_mask_from_real_mask_and(unsigned int m)
{
	__mmask8 res = getComplexMaskFromRealMask_AND(_cvtu32_mask8(m));
	return _cvtmask8_u32(res);
}

__mmask8 getComplexMaskFromRealMask_AND(__mmask8 m)
{
	// 8 incoming bits representing the 8 real-valued elements in a 128-bit
	// register. Broadcast the bits into 8-bit elements of all 1's or all
	// 0's.
	auto wholeElements = _mm_movm_epi8(m);

	// Generate an entire vector of 1's (typically a ternlogic will be used,
	// which is very cheap and can be done in parallel with the movm above,
	// or hoisted when used repeatedly.
	const auto allOnes = _mm_set1_epi16(-1);

	// Extract single mask bits from each 16-bit element which are the
	// logical ANDs of the MSBs of each incoming 8-bit element. Because the
	// movm above generated all 0/1 bits across the whole element the only
	// combinations of values in each 32-bit unit are both all zero, both
	// all one, or one of each. The logical AND of the MSBs can only occur
	// when both 8-bit sub-elements are all ones, so this is equivalent to
	// comparing the 16-bit block as though it were entirely 1, which is a
	// direct equality comparison.

	return _mm_cmp_epi16_mask(wholeElements, allOnes, _MM_CMPINT_EQ);
}
