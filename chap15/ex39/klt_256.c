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

#include <immintrin.h>

#include "klt_256.h"
#include "lkt_intra_block.h"

// clang-format off
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
__declspec(align(16)) short cst_rmc0[8] = {
64, 84, 64, 35, 64, 84, 64, 35
};

__declspec(align(16)) short cst_rmc1[8] = {
64, 35, -64, -84, 64, 35, -64, -84
};

__declspec(align(16)) short cst_rmc2[8] = {
64, -35, -64, 84, 64, -35, -64, 84
};

__declspec(align(16)) short cst_rmc3[8] = {
64, -84, 64, -35, 64, -84, 64, -35
};

__declspec(align(16)) short cst_lmr0[8] = {
29, 55, 74, 84, 29, 55, 74, 84
};

__declspec(align(16)) short cst_lmr1[8] = {
74, 74, 0, -74, 74, 74, 0, -74
};

__declspec(align(16)) short cst_lmr2[8] = {
84, -29, -74, 55, 84, -29, -74, 55
};

__declspec(align(16)) short cst_lmr3[8] = {
55, -84, 74, -29, 55, -84, 74, -29
};
#else
short cst_rmc0[8] __attribute__((aligned(16))) = {
64, 84, 64, 35, 64, 84, 64, 35
};

short cst_rmc1[8] __attribute__((aligned(16))) = {
64, 35, -64, -84, 64, 35, -64, -84
};

short cst_rmc2[8] __attribute__((aligned(16))) = {
64, -35, -64, 84, 64, -35, -64, 84
};

short cst_rmc3[8] __attribute__((aligned(16))) = {
64, -84, 64, -35, 64, -84, 64, -35
};

short cst_lmr0[8] __attribute__((aligned(16))) = {
29, 55, 74, 84, 29, 55, 74, 84
};

short cst_lmr1[8] __attribute__((aligned(16))) = {
74, 74, 0, -74, 74, 74, 0, -74
};

short cst_lmr2[8] __attribute__((aligned(16))) = {
84, -29, -74, 55, 84, -29, -74, 55
};

short cst_lmr3[8] __attribute__((aligned(16))) = {
55, -84, 74, -29, 55, -84, 74, -29
};
#endif

// clang-format on

void klt_256_d(short *input, short *output, int width, int height)
{
	int iX, iY;
	__m256i rmc0 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_rmc0[0]));
	__m256i rmc1 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_rmc1[0]));
	__m256i rmc2 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_rmc2[0]));
	__m256i rmc3 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_rmc3[0]));
	__m256i lmr0 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_lmr0[0]));
	__m256i lmr1 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_lmr1[0]));
	__m256i lmr2 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_lmr2[0]));
	__m256i lmr3 = _mm256_broadcastsi128_si256(
	    _mm_loadu_si128((__m128i *)&cst_lmr3[0]));
	__m256i min32km1 =
	    _mm256_broadcastd_epi32(_mm_cvtsi32_si128(0x7fff7fff));
	__m256i b0, b1, b2, b3, t0, t1, t2, t3;
	__m256i w0, w1, w2, w3;
	short *in_image = input;
	short *out_image = output;
	int hgt = height, wid = width;
	// We implement 1/128 * (Mat_L x (1/128 * (Mat_B x Mat_R))) from the
	// inner most parenthesis
	for (iY = 0; iY < hgt; iY += 4) {
		for (iX = 0; iX < wid; iX += 16) {
			// load row 0 of 4 consecutive 4x4 matrix of word pixels
			b0 = _mm256_loadu_si256(
			    (__m256i *)(in_image + iY * wid + iX));
			// multiply row 0 with columnar vectors of the RHS
			// matrix coefficients
			__MYM_KIP_PXRMC_ROW_4X4WX4(b0, w0, rmc0, rmc1, rmc2,
						   rmc3, min32km1);
			// low 128-bit of garbled row 0, from hi->lo: y07, y05,
			// y06, y04, y03, y01, y02, y00
			b1 = _mm256_loadu_si256(
			    (__m256i *)(in_image + (iY + 1) * wid + iX));
			__MYM_KIP_PXRMC_ROW_4X4WX4(b1, w1, rmc0, rmc1, rmc2,
						   rmc3, min32km1);
			// hi->lo y17, y15, y16, y14, y13, y11, y12, y10
			b2 = _mm256_loadu_si256(
			    (__m256i *)(in_image + (iY + 2) * wid + iX));
			__MYM_KIP_PXRMC_ROW_4X4WX4(b2, w2, rmc0, rmc1, rmc2,
						   rmc3, min32km1);
			b3 = _mm256_loadu_si256(
			    (__m256i *)(in_image + (iY + 3) * wid + iX));
			__MYM_KIP_PXRMC_ROW_4X4WX4(b3, w3, rmc0, rmc1, rmc2,
						   rmc3, min32km1);
			// unscramble garbled middle 2 elements of each 4x4
			// block, then transpose into columnar vectors: t0 has 4
			// consecutive column 0 or 4 4x4 intermediate
			t0 = _mm256_blend_epi16(w0, _mm256_slli_epi64(w1, 16),
						0x22);
			t0 = _mm256_blend_epi16(t0, _mm256_slli_epi64(w2, 32),
						0x44);
			t0 = _mm256_blend_epi16(t0, _mm256_slli_epi64(w3, 48),
						0x88);
			t1 =
			    _mm256_blend_epi16(_mm256_srli_epi64(w0, 32),
					       _mm256_srli_epi64(w1, 16), 0x22);
			t1 = _mm256_blend_epi16(t1, w2, 0x44);
			t1 = _mm256_blend_epi16(t1, _mm256_slli_epi64(w3, 16),
						0x88); // column 1
			t2 = _mm256_blend_epi16(_mm256_srli_epi64(w0, 16), w1,
						0x22);
			t2 = _mm256_blend_epi16(t2, _mm256_slli_epi64(w2, 16),
						0x44);
			t2 = _mm256_blend_epi16(t2, _mm256_slli_epi64(w3, 32),
						0x88); // column 2
			t3 =
			    _mm256_blend_epi16(_mm256_srli_epi64(w0, 48),
					       _mm256_srli_epi64(w1, 32), 0x22);
			t3 = _mm256_blend_epi16(t3, _mm256_srli_epi64(w2, 16),
						0x44);
			t3 = _mm256_blend_epi16(t3, w3, 0x88); // column 3

			// multiply row 0 of the LHS coefficient with 4 columnar
			// vectors of intermediate blocks final output row are
			// arranged in normal order
			__MYM_KIP_LMRXP_ROW_4X4WX4(w0, t0, t1, t2, t3, lmr0,
						   min32km1);
			_mm256_store_si256(
			    (__m256i *)(out_image + iY * wid + iX), w0);

			__MYM_KIP_LMRXP_ROW_4X4WX4(w1, t0, t1, t2, t3, lmr1,
						   min32km1);
			_mm256_store_si256(
			    (__m256i *)(out_image + (iY + 1) * wid + iX), w1);

			__MYM_KIP_LMRXP_ROW_4X4WX4(w2, t0, t1, t2, t3, lmr2,
						   min32km1);
			_mm256_store_si256(
			    (__m256i *)(out_image + (iY + 2) * wid + iX), w2);

			__MYM_KIP_LMRXP_ROW_4X4WX4(w3, t0, t1, t2, t3, lmr3,
						   min32km1);
			_mm256_store_si256(
			    (__m256i *)(out_image + (iY + 3) * wid + iX), w3);
		}
	}
}

bool klt_256_d_check(short *input, short *output, int width, int height)
{
	/*
	 * The algorithm works fine if either width and height are 0.  It just
	 * won't do anything.  width must be divisible by 16 and height must be
	 * divisible by 4.
	 */

	if ((width > 0) && (height > 0)) {
		if ((width % 16 != 0) || (height % 4 != 0))
			return false;

		/*
		 * input and output must be non-NULL.  Output must be 32 byte
		 * aligned.
		 */

		if (!input || !output)
			return false;

		if (((uintptr_t)output) % 32 != 0)
			return false;
	}

	klt_256_d(input, output, width, height);

	return true;
}
