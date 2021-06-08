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

#include "lookup128_novbmi.h"

bool lookup128_novbmi_check(const uint8_t *in, uint8_t *dict, uint8_t *out,
			    size_t len)
{
	/*
	 * in, dict and out must be non-NULL.  dict must contain at least 128
	 * bytes.
	 */

	if (!in || !dict || !out)
		return false;

	/*
	 * len must be > 0 and a multiple of 32.
	 */

	if (len == 0 || len % 32 != 0)
		return false;

	lookup128_novbmi(in, dict, out, len);

	return true;
}
