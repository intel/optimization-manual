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

#ifndef OPTIMISATION_COMMON_H__
#define OPTIMISATION_COMMON_H__

#include <stdbool.h>

#include "../chap5/ex15/supports_avx2.h"

#ifdef __cplusplus
extern "C" {
#endif

int64_t supports_avx512(uint32_t ecx_in, uint32_t *ebx, uint32_t *ecx,
			uint32_t *edx);
bool supports_avx512_skx(void);
bool supports_avx512_clx(void);
bool supports_avx512_icl(void);

#ifdef __cplusplus
}
#endif

#endif
