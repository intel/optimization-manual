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

#include "pixel_shuffler_offset.h"

size_t pixel_shuffler_offset(int base_ofm, int NoOutFMs, int OFM_W, int OFM_H,
			     int ConvOutputX, int ConvOutputY)
{
	// base_ofm - output target location (base_ofm % 16 == 0)
	// SubTileX - X location in quad (0 or 1)
	// SubTileY - Y location in quad (0 or 1)
	// ConvOutputX - X position in the output of the convolution
	// ConvOutputY - Y position in the output of the convolution

	int PostPSNoOutMs = (NoOutFMs / 4);
	int PostPSOptOfmIndex = (base_ofm % PostPSNoOutMs) / 16;
	int QuarterIndex = base_ofm / PostPSNoOutMs;
	int SubTileX = QuarterIndex & 0x1;
	int SubTileY = (QuarterIndex & 0x2) >> 1;
	int PostPSX = ConvOutputX * 2 + SubTileX;
	int PostPSY = ConvOutputY * 2 + SubTileY;
	size_t offset =
	    (OFM_H * OFM_W * PostPSOptOfmIndex + PostPSY * OFM_W + PostPSX) *
	    16;

	return offset;
}
