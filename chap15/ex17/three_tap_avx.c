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

#include <stdint.h>

#include "three_tap_avx.h"

bool three_tap_avx_check(float *a, float *coeff, float *out, size_t len)
{
	/*
	 * a, coeff and out must be non-NULL. a and out must be 32 byte aligned.
	 */

	if (!a || !coeff || !out)
		return false;

	if (((uintptr_t)a) % 32 != 0)
		return false;

	if (((uintptr_t)out) % 32 != 0)
		return false;

	/*
	 * coeff is expected to have at least three elements, the first three of
	 * which are read. out is expected to have len elements and is expected
	 * to be divisible by 8. a is expected to have len + 2 elements.
	 */

	if (len % 8 != 0)
		return false;

	three_tap_avx(a, coeff, out, len);
	return true;
}
