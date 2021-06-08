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

#ifdef _MSC_VER
#include <intrin.h>
#else
#include <x86intrin.h>
#endif
#include <immintrin.h>

#include "fma_unit_count.h"

int64_t rdtsc(void) { return __rdtsc(); }

uint64_t fma_unit_count(void)
{
	int i;
	uint64_t fma_shuf_tpt_test[3];
	uint64_t fma_shuf_tpt_test_min;
	uint64_t fma_only_tpt_test[3];
	uint64_t fma_only_tpt_test_min;
	uint64_t start = 0;
	uint64_t number_of_fma_units_per_core = 2;

	/*********************************************************/
	/* Step 1: Warmup */
	/*********************************************************/

	fma_only_tpt(100000);

	/*********************************************************/
	/* Step 2: Execute FMA and Shuffle TPT Test */
	/*********************************************************/

	for (i = 0; i < 3; i++) {
		start = rdtsc();
		fma_shuffle_tpt(1000);
		fma_shuf_tpt_test[i] = rdtsc() - start;
	}

	/*********************************************************/
	/* Step 3: Execute FMA only TPT Test */
	/*********************************************************/

	for (i = 0; i < 3; i++) {
		start = rdtsc();
		fma_only_tpt(1000);
		fma_only_tpt_test[i] = rdtsc() - start;
	}

	/*********************************************************/
	/* Step 4: Decide if 1 FMA server or 2 FMA server */
	/*********************************************************/

	fma_shuf_tpt_test_min = fma_shuf_tpt_test[0];
	fma_only_tpt_test_min = fma_only_tpt_test[0];
	for (i = 1; i < 3; i++) {
		if ((int)fma_shuf_tpt_test[i] < (int)fma_shuf_tpt_test_min)
			fma_shuf_tpt_test_min = fma_shuf_tpt_test[i];
		if ((int)fma_only_tpt_test[i] < (int)fma_only_tpt_test_min)
			fma_only_tpt_test_min = fma_only_tpt_test[i];
	}

	if (((double)fma_shuf_tpt_test_min / (double)fma_only_tpt_test_min) <
	    1.5)
		number_of_fma_units_per_core = 1;

	/*	printf("%d FMA server\n", number_of_fma_units_per_core); */

	return number_of_fma_units_per_core;
}
