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

#include "mce_avx2.h"

bool mce_avx2_check(uint32_t *out, const uint32_t *in, uint64_t width)
{
	/*
	 * out and in must be non NULL and 32 byte aligned.
	 */

	if (!out || !in)
		return false;

	if (((uintptr_t)out) % 32 != 0)
		return false;

	if (((uintptr_t)in) % 32 != 0)
		return false;

	/*
	 * width must be > 0 and a multiple of 8.
	 */

	if (width == 0 || width % 8 != 0)
		return false;

	mce_avx2(out, in, width);

	return true;
}
