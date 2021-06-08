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

#include "median_sse.h"

bool median_sse_check(float *x, float *y, uint64_t len)
{
	/*
	 * x and y must be non-null and 16 byte aligned
	 */

	if (!x || !y)
		return false;

	if (((uintptr_t)x) % 16 != 0)
		return false;

	if (((uintptr_t)y) % 16 != 0)
		return false;

	/*
	 * len must be divisible by 4.
	 */

	if (len % 4 != 0)
		return false;

	median_sse(x, y, len);

	return true;
}
