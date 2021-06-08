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

#include "software_scatter.h"

bool software_scatter_check(const uint64_t *input, const uint32_t *indices,
			    uint64_t count, float *output)
{
	/*
	 * input, output, and indices must be non-NULL.
	 */

	if (!output || !input || !indices)
		return false;

	/* input must be 64 byte aligned. */

	if (((uintptr_t)input) % 64 != 0)
		return false;

	/* count is specified in bytes.  It must be > 0 and divisible by 64. */

	if (count == 0 || (count & 63))
		return false;

	software_scatter(input, indices, count, output);

	return true;
}
