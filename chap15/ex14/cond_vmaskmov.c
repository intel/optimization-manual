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

#include "cond_vmaskmov.h"

bool cond_vmaskmov_check(float *a, float *b, float *d, float *c, float *e,
			 size_t len)
{
	/*
	 * a, b, d, c and e must be non-null.
	 */

	if (!a || !b || !d || !c || !e)
		return false;

	/*
	 * len must be > 0 and a multiple of 8
	 */

	if (len == 0 || (len % 8) != 0)
		return false;

	cond_vmaskmov(a, b, d, c, e, len);
	return true;
}
