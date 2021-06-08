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

#include "optimisation_common.h"

#define mask_skx_ebx_avx512                                                    \
	((1u << 17) | /* AVX512DQ */                                           \
	 (1u << 24) | /* CWLB */                                               \
	 (1u << 28) | /* AVX512CD */                                           \
	 (1u << 30) | /* AVX512BW */                                           \
	 (1u << 31))  /* AVX512VL */

#define mask_clx_ecx_avx512 (1u << 11) /* VNNI */

#define mask_icl_ebx_avx512 (mask_skx_ebx_avx512 | (1u << 21)) /* IFMA */
#define mask_icl_ecx_avx512                                                    \
	(mask_clx_ecx_avx512 | (1u << 1) | /* VBMI */                          \
	 (1u << 6) |			   /* VBMI2 */                         \
	 (1u << 8) |			   /* GFNI */                          \
	 (1u << 9) |			   /* VAES */                          \
	 (1u << 10) |			   /* VPCLMULQDQ */                    \
	 (1u << 12) |			   /* BITALG */                        \
	 (1u << 14))			   /* VPOPCNTDQ */

#define mask_icl_edx_avx512 (1 << 4) /* FSRM */

static bool supports_avx512_ebx_mask(uint32_t ebx_mask)
{
	uint32_t ebx;
	uint32_t ecx;
	uint32_t edx;

	if (!supports_avx512(0, &ebx, &ecx, &edx))
		return false;

	return (ebx & ebx_mask) == ebx_mask;
}

bool supports_avx512_skx(void)
{
	return supports_avx512_ebx_mask(mask_skx_ebx_avx512);
}

bool supports_avx512_clx(void)
{
	uint32_t ebx;
	uint32_t ecx;
	uint32_t edx;

	if (!supports_avx512(0, &ebx, &ecx, &edx))
		return false;

	if ((ebx & mask_skx_ebx_avx512) != mask_skx_ebx_avx512)
		return false;

	if ((ecx & mask_clx_ecx_avx512) != mask_clx_ecx_avx512)
		return false;

	return true;
}

bool supports_avx512_icl(void)
{
	uint32_t ebx;
	uint32_t ecx;
	uint32_t edx;

	if (!supports_avx512(0, &ebx, &ecx, &edx))
		return false;

	if ((ebx & mask_icl_ebx_avx512) != mask_icl_ebx_avx512)
		return false;

	if ((ecx & mask_icl_ecx_avx512) != mask_icl_ecx_avx512)
		return false;

	if ((edx & mask_icl_edx_avx512) != mask_icl_edx_avx512)
		return false;

	return true;
}
