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

#ifndef SIGMOID_APPROX_H__
#define SIGMOID_APPROX_H__

#include <immintrin.h>

// clang-format off

// coefficients of second order minimax polynomial for sigmoid approximation
#ifdef _MSC_VER
__declspec(align(64)) const float sigmoid_poly2_coeffs[3][16] = {
#else
const float sigmoid_poly2_coeffs[3][16] __attribute__((aligned(64))) = {
#endif
    {
	0.559464f, 0.702775f, 0.869169f, 0.968227f, 0.996341f, 0.999999f, 0.499999f, 0.499973f,
	0.499924f, 0.499791f, 0.499419f, 0.498471f, 0.496119f, 0.491507f, 0.486298f, 0.495135f,
    },
    {
	0.22038f,  0.123901f, 0.042184f, 0.00779019f, 0.000651011f, 1.12481e-7f, 0.250103f, 0.250739f,
	0.251492f, 0.252905f, 0.255751f, 0.260808f,   0.269823f,    0.282225f,   0.292552f, 0.281425f,
    },
    {
	-0.0298035f,  -0.0135297f, -0.00347128f, -0.000483042f, -0.0000289636f, -2.57464e-9f, -0.00292674f, -0.00680854f,
	-0.00968539f, -0.0134544f, -0.0188995f,  -0.0256562f,   -0.0343136f,    -0.0426696f,  -0.0478004f,  -0.0443023f,
    },
};

// clang-format on

inline void sigmoid_poly_2(const __m512 &arg, __m512 &func)
{
	// Load polynomial coefficients into registers (one time operation)
	const __m512 sigmoid_coeff0 = _mm512_load_ps(sigmoid_poly2_coeffs[0]);
	const __m512 sigmoid_coeff1 = _mm512_load_ps(sigmoid_poly2_coeffs[1]);
	const __m512 sigmoid_coeff2 = _mm512_load_ps(sigmoid_poly2_coeffs[2]);

	// Extract signs of args
	const __m512 ps_sign_filter =
	    _mm512_castsi512_ps(_mm512_set1_epi32(0x7FFFFFFF));

	__mmask16 signs = _mm512_movepi32_mask(_mm512_castps_si512(arg));
	__m512 abs_arg = _mm512_and_ps(arg, ps_sign_filter);

	// Compute approximation intervals out of args' exponent and MSB and
	// restrict number of intervals to 16
	const __m512i lut_low = _mm512_set1_epi32(246);
	const __m512i lut_high = _mm512_set1_epi32(261);

	__m512i indices = _mm512_srli_epi32(_mm512_castps_si512(abs_arg), 22);
	indices = _mm512_max_epi32(indices, lut_low);
	indices = _mm512_min_epi32(indices, lut_high);

	/*
	 * Approximate
	 */
	__m512 func_p0 = _mm512_permutexvar_ps(indices, sigmoid_coeff0);
	__m512 func_p1 = _mm512_permutexvar_ps(indices, sigmoid_coeff1);
	__m512 func_p2 = _mm512_permutexvar_ps(indices, sigmoid_coeff2);
	func = _mm512_fmadd_ps(abs_arg, func_p2, func_p1);
	func = _mm512_fmadd_ps(abs_arg, func, func_p0);

	// Account for args' sign
	const __m512 ps_ones = _mm512_set1_ps( 1.0 );
	func = _mm512_mask_sub_ps(func, signs, ps_ones, func);
}

#endif
