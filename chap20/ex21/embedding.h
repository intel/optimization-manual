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

#ifndef AMX_EMBEDDING
#define AMX_EMBEDDING

#include <stdbool.h>
#include <stdint.h>

#define CACHE_LINE_SIZE 64L
#define FLOATS_PER_CACHE_LINE (CACHE_LINE_SIZE / sizeof(float))

#ifdef __cplusplus
extern "C" {
#endif
void prefetched_embedding(uint32_t *a, float *e, float *c, size_t num_indices,
			  float scale, float bias, size_t lookahead);
bool prefetched_embedding_check(uint32_t *a, float *e, float *c,
				size_t num_indices, float scale, float bias,
				size_t lookahead);

void noprefetched_embedding(uint32_t *a, float *e, float *c, size_t num_indices,
			    float scale, float bias);

#ifdef __cplusplus
}
#endif

#endif
