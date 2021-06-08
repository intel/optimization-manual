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

#include "expand_avx2.h"

bool expand_avx2_check(int32_t *out, int32_t *in, size_t N)
{
	/*
	 * in and out must be non NULL and in must be 32 byte aligned.
	 */

	if (!out || !in)
		return false;

	if (((uintptr_t)in) % 32 != 0)
		return false;

	/*
	 * N must be > 0 and a multiple of 8.
	 */

	if (N == 0 || N % 8 != 0)
		return false;

	expand_avx2(out, in, N);

	return true;
}
