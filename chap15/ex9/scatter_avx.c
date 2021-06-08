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

#include "scatter_avx.h"

bool scatter_avx_check(int32_t *in, int32_t *out, uint32_t *index, size_t len)
{
	/*
	 * in, out and index must be non-null.  in must be 32 byte aligned.
	 */

	if (!in || !out || !index)
		return false;

	if (((uintptr_t)in) % 32 != 0)
		return false;

	/*
	 * len must be > 0 and a multiple of 8
	 */

	if (len == 0 || len % 8 != 0)
		return false;

	scatter_avx(in, out, index, len);
	return true;
}
