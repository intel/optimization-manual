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

#include "complex_conv_avx_stride.h"

bool complex_conv_avx_stride_check(complex_num *complex_buffer,
				   float *real_buffer, float *imaginary_buffer,
				   size_t len)
{
	/*
	 * Buffers must be non-NULL.
	 */

	if (!complex_buffer || !real_buffer || !imaginary_buffer)
		return false;

	/*
	 * len must greater than 0 and a multiple of 8
	 */

	if (len == 0 || len % 8 != 0)
		return false;

	complex_conv_avx_stride(complex_buffer, real_buffer, imaginary_buffer,
				len);

	return true;
}
