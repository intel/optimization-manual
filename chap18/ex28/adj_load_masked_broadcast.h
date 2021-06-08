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

#ifndef ADJ_LOAD_MASKED_BROADCAST_H_
#define ADJ_LOAD_MASKED_BROADCAST_H_

#include <stdbool.h>
#include <stdint.h>

#include "elem_struct.h"

#ifdef __cplusplus
extern "C" {
#endif

void adj_load_masked_broadcast(int64_t len, const int32_t *indices,
			       const elem_struct_t *elems, double *out);
bool adj_load_masked_broadcast_check(int64_t len, const int32_t *indices,
				     const elem_struct_t *elems, double *out);

#ifdef __cplusplus
}
#endif

#endif
