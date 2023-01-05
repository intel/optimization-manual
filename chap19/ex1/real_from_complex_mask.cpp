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

#include "real_from_complex_mask.h"

unsigned int get_real_mask_from_complex_mask(unsigned int m)
{
	__mmask8 res = getRealMaskFromComplexMask(_cvtu32_mask8(m));
	return _cvtmask8_u32(res);
}

__mmask8 getRealMaskFromComplexMask(__mmask8 m)
{

	// 4 incoming bits representing the 4 complex elements in a 128-bit
	// register. Each mask bit is converted into an entire element in a
	// vector register where a 0-mask generates 32x0, and a 1-mask generates
	// 32x1. For example 0010 -> [000....00], [000...000], [111....111],
	// [000....000]
	auto wholeElements = _mm_movm_epi32(m);

	// Each complex element can now be treated as a pair of 16-bit elements
	// instead, and the MSB of each 16-bit unit can extracted as a mask bit
	// in its own right.
	return _mm_movepi16_mask(wholeElements);
}
