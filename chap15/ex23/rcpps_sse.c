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

#include "rcpps_sse.h"

bool rcpps_sse_check(float *in1, float *in2, float *out, size_t len)
{
	/*
	 * in1, in2 and out must be non-NULL.
	 */

	if (!in1 || !in2 || !out)
		return false;

	/*
	 * len is the number of elements.  It must be greater than 0 and
	 * divisible by 4.
	 */

	if ((len == 0) || ((len % 4) != 0))
		return false;

	rcpps_sse(in1, in2, out, len);

	return true;
}
