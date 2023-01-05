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

#ifdef __linux__
#include <asm/prctl.h>
#include <sys/syscall.h>
#include <unistd.h>
#endif

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

#define mask_avx512_edx_fp16 (1 << 23) /* AVX512 FP16 */

#define mask_xcr0_amx ((1 << 17) | (1 << 18)) /* XTILECFG/XTILEDATA */

static bool supports_avx512_ebx_mask(uint32_t ebx_mask)
{
	uint32_t ebx;
	uint32_t ecx;
	uint32_t edx;

	if (!supports_avx512(&ebx, &ecx, &edx))
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

	if (!supports_avx512(&ebx, &ecx, &edx))
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

	if (!supports_avx512(&ebx, &ecx, &edx))
		return false;

	if ((ebx & mask_icl_ebx_avx512) != mask_icl_ebx_avx512)
		return false;

	if ((ecx & mask_icl_ecx_avx512) != mask_icl_ecx_avx512)
		return false;

	if ((edx & mask_icl_edx_avx512) != mask_icl_edx_avx512)
		return false;

	return true;
}

bool supports_avx512_fp16(void)
{
	uint32_t ebx;
	uint32_t ecx;
	uint32_t edx;

	if (!supports_avx512(&ebx, &ecx, &edx))
		return false;

	if ((ebx & mask_skx_ebx_avx512) != mask_skx_ebx_avx512)
		return false;

	if ((edx & mask_avx512_edx_fp16) != mask_avx512_edx_fp16)
		return false;

	return true;
}

bool supports_amx(void)
{
	if (!cpu_supports_amx())
		return false;

#ifdef __linux__
#ifndef ARCH_GET_XCOMP_PERM
#define ARCH_GET_XCOMP_PERM 0x1022
#define ARCH_REQ_XCOMP_PERM 0x1023
#endif
	unsigned long mask = 0;

	if (syscall(SYS_arch_prctl, ARCH_GET_XCOMP_PERM, &mask))
		return false;

	if ((mask & mask_xcr0_amx) == mask_xcr0_amx)
		return true;

	if (syscall(SYS_arch_prctl, ARCH_REQ_XCOMP_PERM, 18))
		return false;
#endif

	return true;
}
