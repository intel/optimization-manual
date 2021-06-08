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

#ifndef ELTWISE_H__
#define ELTWISE_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <immintrin.h>
#include <stdbool.h>
#include <stdint.h>

__m128i eltwise(__m512 resf, uint8_t *eltwise_data, float next_qfactor,
		float eltwise_dqfactor, size_t ew_offset, bool signed_residual,
		bool relu);
void test_eltwise(int8_t *res8s, int8_t *res8v);
#ifdef __cplusplus
}
#endif

#endif
