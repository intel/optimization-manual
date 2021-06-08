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

#include "s2s_vscatterdps.h"

bool s2s_vscatterdps_check(int64_t len, float *imaginary_buffer,
			   float *real_buffer, complex_num *complex_buffer)
{
	/* complex_buffer, imaginary_buffer, real_buffer must be non-null */

	if (!complex_buffer || !imaginary_buffer || !real_buffer)
		return false;

	/* len must be >= 16 and divisible by 16 */

	if ((len < 16) || (len % 16))
		return false;

	s2s_vscatterdps(len, imaginary_buffer, real_buffer, complex_buffer);

	return true;
}
