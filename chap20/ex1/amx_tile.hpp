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

#ifndef AMX_TILE_HPP
#define AMX_TILE_HPP

#include <string.h>

// clang-format off

template<size_t rows, size_t bytes_cols> class tile {
public:
	friend void tilezero(tile &t) { memset(t.v, 0, sizeof(v)); }
	friend void tileload(tile &t, void *src, size_t bytes_stride)
	{
		for (size_t row = 0; row < rows; ++row)
			for (size_t bcol = 0; bcol < bytes_cols; ++bcol)
				t.v[row][bcol] = static_cast<int8_t *>(
				    src)[row * bytes_stride + bcol];
	}
	friend void tilestore(tile &t, void *dst, size_t bytes_stride)
	{
		for (size_t row = 0; row < rows; ++row)
			for (size_t bcol = 0; bcol < bytes_cols; ++bcol)
				static_cast<int8_t *>(
				    dst)[row * bytes_stride + bcol] =
				    t.v[row][bcol];
	}

	template <class TC, class TA, class TB>
	friend void tdp(TC &tC, TA &tA, TB &tB);

private:
	int8_t v[rows][bytes_cols];
};

// clang-format on

template <class TC, class TA, class TB> void tdp(TC &tC, TA &tA, TB &tB)
{
	int32_t v;
	for (size_t m = 0; m < TILE_M; m++)
		for (size_t k = 0; k < TILE_K / KPACK; k++)
			for (size_t n = 0; n < TILE_N; n++) {
				memcpy(&v, &tC.v[m][n * 4], sizeof(v));
				v += tA.v[m][k * 4] * tB.v[k][n * 4];
				v += tA.v[m][k * 4 + 1] * tB.v[k][n * 4 + 1];
				v += tA.v[m][k * 4 + 2] * tB.v[k][n * 4 + 2];
				v += tA.v[m][k * 4 + 3] * tB.v[k][n * 4 + 3];
				memcpy(&tC.v[m][n * 4], &v, sizeof(v));
			}
}

#endif
