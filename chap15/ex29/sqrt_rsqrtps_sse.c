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

#include "sqrt_rsqrtps_sse.h"

bool sqrt_rsqrtps_sse_check(float *in, float *out, size_t len)
{
	/*
	 * in and out must be non-NULL.
	 */

	if (!in || !out)
		return false;

	/*
	 * len is the number of elements.  It must be greater than 0 and
	 * divisible by 4.
	 */

	if ((len == 0) || ((len % 4) != 0))
		return false;

	sqrt_rsqrtps_sse(in, out, len);

	return true;
}
