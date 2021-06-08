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

#include "transpose_avx512.h"

bool transpose_avx512_check(uint16_t *out, const uint16_t *in)
{
	/*
	 * out and in must be non-NULL and 64 byte aligned.
	 * The function expects in to contain 50 8x8 int16
	 * matrices that are contiguous in memory.  out must
	 * be the same size as in.
	 */

	if (!out || !in)
		return false;

	if (((uintptr_t)in) % 64 != 0)
		return false;

	if (((uintptr_t)out) % 64 != 0)
		return false;

	transpose_avx512(out, in);

	return true;
}
