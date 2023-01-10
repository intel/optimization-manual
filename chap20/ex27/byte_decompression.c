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

#include "byte_decompression.h"

void byte_decompression(uint8_t *compressed_ptr,
			__mmask64 *compression_masks_ptr,
			uint8_t *decompressed_ptr, int num)
{
	for (int i = 0; i < num; i++) {
		__m512i compressed = _mm512_load_epi32(compressed_ptr);
		__mmask64 mask = _load_mask64(compression_masks_ptr);
		__m512i decompressed_vec =
		    _mm512_maskz_expand_epi8(mask, compressed);
		_mm512_store_epi32(decompressed_ptr, decompressed_vec);
		decompressed_ptr += 64; // 64 bytes per decompressed row
		compressed_ptr +=
		    _mm_popcnt_u64(mask); // advance compressed pointer by
					  // number of non-zero elements
		compression_masks_ptr++; // 8 bitmask bytes per decompressed row
	}
}
