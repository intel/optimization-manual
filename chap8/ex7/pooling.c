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

#include "pooling.h"

#include <stdio.h>
#include <stdlib.h>

static __m512 init_data(float *outputFeatureMaps)
{
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(64)) float output[16];
#else
	float output[16] __attribute__((aligned(64)));
#endif

	for (size_t i = 0; i < 16; i++) {
		outputFeatureMaps[i] = 0.0;
		output[i] = rand() / ((float)RAND_MAX);
	}

	return _mm512_cvtepi32_ps(_mm512_load_epi32(&output[0]));
}

void pooling(__m512 resf, void *outputFeatureMaps, int BlockOffsetOFM,
	     int OFMItr)
{
	__m512 pool_factor = _mm512_set1_ps((float)1.0 / 64);
	// resf is the 16 float values as computed in Basic PostConv code sample
	resf = _mm512_mul_ps(resf, pool_factor); // divide by 64
	// The pool offset depends only on the current OFM (OFMItr).
	int pool_offset = (BlockOffsetOFM + OFMItr);
	float *pool_dest = (float *)(outputFeatureMaps) + pool_offset;
	__m512 prev_val = _mm512_load_ps((const __m512 *)(pool_dest));
	__m512 res_tmp_ps = _mm512_add_ps(resf, prev_val);

	_mm512_store_ps((__m512 *)pool_dest, res_tmp_ps);
}

void test_pooling(float *outputFeatureMaps, float *expected)
{
	__m512 resf = init_data(outputFeatureMaps);

	_mm512_store_ps(expected, resf);

	for (size_t i = 0; i < 16; i++)
		expected[i] /= 64.0;

	pooling(resf, outputFeatureMaps, 0, 0);
}
