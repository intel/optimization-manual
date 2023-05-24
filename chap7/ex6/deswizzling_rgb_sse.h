/*
 * Copyright (C) 2023 by Intel Corporation
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

#ifndef DESWIZZLING_RGB_SSE_H__
#define DESWIZZLING_RGB_SSE_H__

#include <stdbool.h>
#include <stdint.h>

#include "vertex_struct.h"

#ifdef __cplusplus
extern "C" {
#endif
void deswizzling_rgb_sse(Vertex_soa *in, Vertex_aos *out);
bool deswizzling_rgb_sse_check(Vertex_soa *in, Vertex_aos *out);
#ifdef __cplusplus
}
#endif

#endif
