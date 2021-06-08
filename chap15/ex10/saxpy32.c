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

#include "saxpy32.h"

bool saxpy32_check(float *src, float *src2, size_t len, float *dst, float alpha)
{
	/*
	 * src, src2 and dst must be non-null.
	 */

	if (!src || !src2 || !dst)
		return false;

	/*
	 * len is specified in bytes and not elements.  It must be > 0 and a
	 * multiple of 64
	 */

	if (len == 0 || len % 64 != 0)
		return false;

	saxpy32(src, src2, len, dst, alpha);
	return true;
}
