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

#ifndef SIGMOID_SCALEF_H__
#define SIGMOID_SCALEF_H__

#include <immintrin.h>

inline void sigmoid_scalef(const __m512 &arg, __m512 &func)
{

	/* These initialisers have been moved into the function so that they
	 * are not statically initialised.  This way the resulting binary can
	 * be run on machines that don't support AVX-512 and the CPUID check
	 * can be used to skip the test.  They can be moved back outside the
	 * function, as they are in the Optimisation manual, if an AVX-512
	 * only build is being created.
	 */

	const __m512 ps_ones = _mm512_set1_ps(1.0);
	const __m512 half = _mm512_set1_ps(0.5f);
	const __m512 minus_log2_e = _mm512_set1_ps(-1.442695f);
	const __m512 ln2sq_over_2 = _mm512_set1_ps(0.240226507f);
	const __m512 ln2__ln2sq_over_2 = _mm512_set1_ps(0.452920674f);
	const __m512 one__ln2sq_over_8 = _mm512_set1_ps(0.713483036f);

	__m512 x = _mm512_fmadd_ps(arg, minus_log2_e, half);
	__m512 y = _mm512_reduce_ps(x, 1);
	__m512 _2y =
	    _mm512_fmadd_ps(_mm512_fmadd_ps(y, ln2sq_over_2, ln2__ln2sq_over_2),
			    y, one__ln2sq_over_8);
	__m512 exp = _mm512_scalef_ps(_2y, x);
	func = _mm512_rcp14_ps(_mm512_add_ps(exp, ps_ones));
}

#endif
