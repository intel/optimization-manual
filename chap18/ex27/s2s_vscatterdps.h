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

#ifndef S2S_VSCATTERDPS_H_
#define S2S_VSCATTERDPS_H_

#include <stdbool.h>
#include <stdint.h>

#include "complex_num.h"

#ifdef __cplusplus
extern "C" {
#endif

void s2s_vscatterdps(int64_t len, float *imaginary_buffer, float *real_buffer,
		     complex_num *complex_buffer);
bool s2s_vscatterdps_check(int64_t len, float *imaginary_buffer,
			   float *real_buffer, complex_num *complex_buffer);

#ifdef __cplusplus
}
#endif

#endif
