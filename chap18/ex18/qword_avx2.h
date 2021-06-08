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

#ifndef QWORD_AVX2_H__
#define QWORD_AVX2_H__

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void qword_avx2_ass(const int64_t *a, const int64_t *b, int64_t *c,
		    uint64_t count);
bool qword_avx2_ass_check(const int64_t *a, const int64_t *b, int64_t *c,
			  uint64_t count);
void qword_avx2_intrinsics(const int64_t *a, const int64_t *b, int64_t *c,
			   uint64_t count);
bool qword_avx2_intrinsics_check(const int64_t *a, const int64_t *b, int64_t *c,
				 uint64_t count);

#ifdef __cplusplus
}
#endif

#endif
