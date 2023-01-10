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

#include "int8_conv_test.h"
#include "int8_conv.h"
#include <stdlib.h>

void int8_conv_init(uint32_t *dwords, size_t max_elements, __m512i *vecs,
		    size_t max_vecs)
{
	for (size_t i = 0; i < max_elements; i++)
		dwords[i] = rand() % 384;

	for (size_t i = 0; i < max_vecs; i++)
		vecs[i] = _mm512_load_epi32(&dwords[i * 16]);
}

void int8_conv_pack_dwords_to_bytes(__m512i *vecs, uint8_t *bytes)
{
	_mm512_store_epi32(bytes, Pack_DwordsToBytes(vecs));
}
