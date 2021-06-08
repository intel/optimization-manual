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

#include "transform_sse.h"

bool transform_sse_check(float *cos_sin_teta_vec, float *sin_cos_teta_vec,
			 float *in, float *out, size_t len)
{
	/*
	 * cos_sin_teta_vec and sin_cos_teta_vec must be non NULL
	 */

	if (!cos_sin_teta_vec || !sin_cos_teta_vec)
		return false;

	/*
	 * in and out must be non NULL.  out must be 32 byte aligned.
	 */

	if (!in || !out)
		return false;

	if (((uintptr_t)out) % 16 != 0)
		return false;

	/*
	 * len must be > 0 and divisible by 8.
	 */

	if ((len == 0) || (len % 8 != 0))
		return false;

	transform_sse(cos_sin_teta_vec, sin_cos_teta_vec, in, out, len);

	return true;
}
