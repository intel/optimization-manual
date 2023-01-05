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

#ifndef AMX_INTERLEAVED_GEMM_ASS_H
#define AMX_INTERLEAVED_GEMM_ASS_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef _MSC_VER
__pragma(pack(push, 1)) struct tc_ {
	uint8_t palette_id;
	uint8_t startRow;
	uint8_t reserved[14];
	uint16_t cols[16];
	uint8_t rows[16];
};

__pragma(pack(pop))
#else
struct tc_ {
	uint8_t palette_id;
	uint8_t startRow;
	uint8_t reserved[14];
	uint16_t cols[16];
	uint8_t rows[16];
} __attribute__((__packed__));
#endif

    // clang-format off

typedef struct tc_ tc;

#ifdef __cplusplus
extern "C" {
#endif

void amx_interleaved_gemm_ass(int32_t *c, const int8_t *a,
			      const int8_t *b, const tc *config);

#ifdef __cplusplus
}
#endif

#endif
