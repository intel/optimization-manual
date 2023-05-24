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

#include "transform_avx512.h"

bool transform_avx512_check(float *cos_sin_theta_vec, float *sin_cos_theta_vec,
			    float *in, float *out, size_t len)
{
	/*
	 * cos_sin_theta_vec and float *sin_cos_theta_vec must be non-NULL.
	 */

	if (!cos_sin_theta_vec || !sin_cos_theta_vec)
		return false;

	/*
	 * in and out must be non NULL.  Out must be 64 byte aligned.
	 */

	if (!in || !out)
		return false;

	if (((uintptr_t)out) % 64 != 0)
		return false;

	/*
	 * len must be > 0 and divisible by 32.
	 */

	if (len == 0 || len % 32 != 0)
		return false;

	transform_avx512(cos_sin_theta_vec, sin_cos_theta_vec, in, out, len);

	return true;
}
