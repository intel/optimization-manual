/*
 * Copyright (C) 2022 by Intel Corporation
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

#include "vnni_to_vnni_bf16_trans.h"

bool vnni_to_vnni_bf16_trans_check(const bfloat_16 *input, bfloat_16 *output)
{
	/*
	 * input is a 16x16 matrix in VNNI format.  Original linear matrix is
	 * 32x8 bf16 values.  output is a 4x64 matrix. both must be non-NULL.
	 */

	if (!input || !output)
		return false;

	vnni_to_vnni_bf16_trans(input, output);

	return true;
}
