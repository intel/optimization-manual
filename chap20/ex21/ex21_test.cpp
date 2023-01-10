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

#include "optimisation_common.h"

#include "gtest/gtest.h"

#include <math.h>
#include <stdint.h>
#include <xmmintrin.h>

#include "embedding.h"

#define NUM_64B_BLOCKS ((1024L * 1024L) / 64L)
#define NUM_INDICES (16 * 1024)
#define LOOKAHEAD 20

TEST(amx_21, amx_prefetch_embedding)
{
	int retval = 1;
	float *e = NULL;
	uint32_t *a = NULL;
	float *c = NULL;
	float scale = 2.0;
	float bias = 0.3;

	if (!supports_avx512_skx())
		GTEST_SKIP_("AVX-512 not supported, skipping test");

	srand(0);

	e = static_cast<float *>(
	    _mm_malloc(NUM_64B_BLOCKS * CACHE_LINE_SIZE, CACHE_LINE_SIZE));
	if (!e)
		goto cleanup;

	a = static_cast<uint32_t *>(
	    malloc(sizeof(*a) * (NUM_INDICES + LOOKAHEAD)));
	if (!a)
		goto cleanup;

	c = static_cast<float *>(
	    _mm_malloc(NUM_INDICES * CACHE_LINE_SIZE, CACHE_LINE_SIZE));
	if (!e)
		goto cleanup;

	for (size_t i = 0; i < NUM_64B_BLOCKS * FLOATS_PER_CACHE_LINE; i++)
		e[i] = ((float)rand()) / (float)RAND_MAX;

	for (size_t i = 0; i < NUM_INDICES; i++)
		a[i] = rand() % NUM_64B_BLOCKS;
	for (size_t i = NUM_INDICES; i < NUM_INDICES + LOOKAHEAD; i++)
		a[i] = 0;

	ASSERT_EQ(prefetched_embedding_check(a, e, c, NUM_INDICES, scale, bias,
					     LOOKAHEAD),
		  true);

	for (size_t i = 0; i < NUM_INDICES; i++) {
		float *a_ptr =
		    &e[static_cast<size_t>(a[i]) * FLOATS_PER_CACHE_LINE];
		float *c_ptr = &c[i * FLOATS_PER_CACHE_LINE];
		for (size_t j = 0; j < FLOATS_PER_CACHE_LINE; j++)
			ASSERT_FLOAT_EQ(fmaf(a_ptr[j], scale, bias), c_ptr[j]);
	}

	ASSERT_EQ(prefetched_embedding_check(NULL, e, c, NUM_INDICES, scale,
					     bias, LOOKAHEAD),
		  false);
	ASSERT_EQ(prefetched_embedding_check(a, NULL, c, NUM_INDICES, scale,
					     bias, LOOKAHEAD),
		  false);
	ASSERT_EQ(prefetched_embedding_check(a, e, NULL, NUM_INDICES, scale,
					     bias, LOOKAHEAD),
		  false);
	ASSERT_EQ(prefetched_embedding_check(a, &e[1], c, NUM_INDICES, scale,
					     bias, LOOKAHEAD),
		  false);
	ASSERT_EQ(prefetched_embedding_check(a, e, &c[1], NUM_INDICES, scale,
					     bias, LOOKAHEAD),
		  false);

	retval = 0;

cleanup:
	_mm_free(c);
	free(a);
	_mm_free(e);

	ASSERT_EQ(retval, 0);
}
