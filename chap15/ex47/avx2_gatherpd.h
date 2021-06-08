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

#ifndef AVX2_GATHERPD_H__
#define AVX2_GATHERPD_H__

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "complex_num.h"

#ifdef __cplusplus
extern "C" {
#endif
void avx2_gatherpd(size_t len, uint32_t *index_buffer, double *imaginary_buffer,
		   double *real_buffer, complex_num *complex_buffer);
bool avx2_gatherpd_check(size_t len, uint32_t *index_buffer,
			 double *imaginary_buffer, double *real_buffer,
			 complex_num *complex_buffer);

#ifdef __cplusplus
}
#endif

#endif
