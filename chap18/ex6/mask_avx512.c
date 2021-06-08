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

#include "mask_avx512.h"

bool mask_avx512_check(uint32_t *a, uint32_t *b, uint32_t *c, size_t N)
{
	/*
	 * a, b and c must be non NULL and 64 byte aligned.
	 */

	if (!a || !b || !c)
		return false;

	if (((uintptr_t)a) % 64 != 0)
		return false;

	if (((uintptr_t)b) % 64 != 0)
		return false;

	if (((uintptr_t)c) % 64 != 0)
		return false;

	/*
	 * N must be > 0 and a multiple of 16.
	 */

	if (N == 0 || N % 16 != 0)
		return false;

	mask_avx512(a, b, c, N);

	return true;
}
