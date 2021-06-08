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

#include "decompress_novbmi.h"

bool decompress_novbmi_check(int len, uint8_t *out, const uint8_t *in)
{
	/*
	 * out and in must be non NULL. The size of out should be equal
	 * to len.  The size of in should be (len / 8) * 5.
	 */

	if (!out || !in)
		return false;

	/* len must be > 0 and a multiple of 8 */

	if (len == 0 || len % 8 != 0)
		return false;

	decompress_novbmi(len, out, in);

	return true;
}
