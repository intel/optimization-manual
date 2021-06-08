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

	.globl _vblendps_transpose
	.globl vblendps_transpose

	# void vblendps_transpose(float *in[8], float *out[8], size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_vblendps_transpose:
vblendps_transpose:

	mov rcx, rdi    # movrcx, inpBuf
	mov r10, rdx    # movr10, NumOfLoops
	mov rdx, rsi    # movrdx, outBuf

loop1:
	vmovaps ymm9, [rcx]
	vmovaps ymm10, [rcx+32]
	vmovaps ymm11, [rcx+64]
	vmovaps ymm12, [rcx+96]
	vmovaps ymm13, [rcx+128]
	vmovaps ymm14, [rcx+160]
	vmovaps ymm15, [rcx+192]
	vmovaps ymm2, [rcx+224]
	vunpcklps ymm6, ymm9, ymm10
	vunpcklps ymm1, ymm11, ymm12
	vunpckhps ymm8, ymm9, ymm10
	vunpcklps ymm0, ymm13, ymm14
	vunpcklps ymm9, ymm15, ymm2
	vshufps ymm3, ymm6, ymm1, 0x4E
	vblendps ymm10, ymm6, ymm3, 0xCC
	vshufps ymm6, ymm0, ymm9, 0x4E
	vunpckhps ymm7, ymm11, ymm12
	vblendps ymm11, ymm0, ymm6, 0xCC
	vblendps ymm12, ymm3, ymm1, 0xCC
	vperm2f128 ymm3, ymm10, ymm11, 0x20
	vmovaps [rdx], ymm3
	vunpckhps ymm5, ymm13, ymm14
	vblendps ymm13, ymm6, ymm9, 0xCC
	vunpckhps ymm4, ymm15, ymm2
	vperm2f128 ymm2, ymm12, ymm13, 0x20
	vmovaps 32[rdx], ymm2
	vshufps ymm14, ymm8, ymm7, 0x4E
	vblendps ymm15, ymm14, ymm7, 0xCC
	vshufps ymm7, ymm5, ymm4, 0x4E
	vblendps ymm8, ymm8, ymm14, 0xCC
	vblendps  ymm5, ymm5, ymm7, 0xCC
	vperm2f128 ymm6, ymm8, ymm5, 0x20
	vmovaps 64[rdx], ymm6
	vblendps ymm4, ymm7, ymm4, 0xCC
	vperm2f128 ymm7, ymm15, ymm4, 0x20
	vmovaps 96[rdx], ymm7
	vperm2f128 ymm1, ymm10, ymm11, 0x31
	vperm2f128 ymm0, ymm12, ymm13, 0x31
	vmovaps 128[rdx], ymm1
	vperm2f128 ymm5, ymm8, ymm5, 0x31
	vperm2f128 ymm4, ymm15, ymm4, 0x31
	vmovaps  160[rdx], ymm0
	vmovaps  192[rdx], ymm5
	vmovaps  224[rdx], ymm4	
	dec r10
	jnz loop1

	vzeroupper
	ret
