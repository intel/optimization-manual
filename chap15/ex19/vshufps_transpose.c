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

#include <stdint.h>

#include "vshufps_transpose.h"

bool vshufps_transpose_check(float in[][8], float out[][8], size_t len)
{
	/*
	 * in and out must be non-NULL. in and out must be 32 byte aligned.
	 */

	if (!in || !out)
		return false;

	if (((uintptr_t)in) % 32 != 0)
		return false;

	if (((uintptr_t)out) % 32 != 0)
		return false;

	/*
	 * len is the matrix width and height divided by 8.  It must be greater
	 * than 0.
	 */

	if (len == 0)
		return false;

	vshufps_transpose(in, out, len);

	return true;
}
