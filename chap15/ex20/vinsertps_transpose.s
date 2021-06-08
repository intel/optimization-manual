#
# Copyright (C) 2021 by Intel Corporation
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

	.intel_syntax noprefix

	.globl _vinsertps_transpose
	.globl vinsertps_transpose

	# void vinsertps_transpose(float *in[8], float *out[8], size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_vinsertps_transpose:
vinsertps_transpose:

	mov rcx, rdi    # mov rcx, inpBuf
	mov r10, rdx    # mov r10, NumOfLoops
	mov rdx, rsi    # mov rdx, outBuf

loop1:
	vmovaps xmm0, [rcx]
	vinsertf128 ymm0, ymm0, [rcx + 128], 1
	vmovaps xmm1, [rcx + 32]
	vinsertf128 ymm1, ymm1, [rcx + 160], 1
	vunpcklpd ymm8, ymm0, ymm1
	vunpckhpd ymm9, ymm0, ymm1
	vmovaps xmm2, [rcx+64]
	vinsertf128 ymm2, ymm2, [rcx + 192], 1
	vmovaps	xmm3, [rcx+96]
	vinsertf128 ymm3, ymm3, [rcx + 224], 1
	vunpcklpd ymm10, ymm2, ymm3
	vunpckhpd ymm11, ymm2, ymm3
	vshufps	ymm4, ymm8, ymm10, 0x88
	vmovaps	[rdx], ymm4
	vshufps	ymm5, ymm8, ymm10, 0xDD
	vmovaps	[rdx+32], ymm5
	vshufps	ymm6, ymm9, ymm11, 0x88
	vmovaps	[rdx+64], ymm6
	vshufps	ymm7, ymm9, ymm11, 0xDD
	vmovaps	[rdx+96], ymm7
	vmovaps xmm0, [rcx+16]
	vinsertf128 ymm0, ymm0, [rcx + 144], 1
	vmovaps xmm1, [rcx + 48]
	vinsertf128 ymm1, ymm1, [rcx + 176], 1
	vunpcklpd ymm8, ymm0, ymm1
	vunpckhpd ymm9, ymm0, ymm1
	vmovaps xmm2, [rcx+80]
	vinsertf128 ymm2, ymm2, [rcx + 208], 1
	vmovaps xmm3, [rcx+112]
	vinsertf128 ymm3, ymm3, [rcx + 240], 1
	vunpcklpd ymm10, ymm2, ymm3
	vunpckhpd ymm11, ymm2, ymm3
	vshufps ymm4, ymm8, ymm10, 0x88
	vmovaps [rdx+128], ymm4
	vshufps ymm5, ymm8, ymm10, 0xDD
	vmovaps [rdx+160], ymm5
	vshufps ymm6, ymm9, ymm11, 0x88
	vmovaps [rdx+192], ymm6
	vshufps ymm7, ymm9, ymm11, 0xDD
	vmovaps [rdx+224], ymm7
	dec r10
	jnz loop1

	vzeroupper
	ret
