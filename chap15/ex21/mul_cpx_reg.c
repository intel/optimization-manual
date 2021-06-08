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

#include "mul_cpx_reg.h"

bool mul_cpx_reg_check(complex_num *in1, complex_num *in2, complex_num *out,
		       size_t len)
{
	/*
	 * in1, in2 and out must be non-NULL and 32 byte aligned.
	 */

	if (!in1 || !in2 || !out)
		return false;

	if (((uintptr_t)in1) % 32 != 0)
		return false;

	if (((uintptr_t)in2) % 32 != 0)
		return false;

	if (((uintptr_t)out) % 32 != 0)
		return false;

	/*
	 * len must be greater than 0 and divisible by 8
	 */

	if ((len == 0) || ((len % 8) != 0))
		return false;

	mul_cpx_reg(in1, in2, out, len);

	return true;
}
