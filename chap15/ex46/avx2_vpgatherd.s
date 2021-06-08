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
	
	.globl _avx2_vpgatherd
	.globl avx2_vpgatherd

	# void avx2_vpgatherd(size_t len, complex_num* complex_buffer, float* imaginary_buffer,
	#              	      float* real_buffer);
	# On entry:
	#     rdi = len (length in elements of )
	#     rsi = complex_buffer
	#     rdx = imaginary_buffer
	#     rcx = real_buffer

	.text

_avx2_vpgatherd:
avx2_vpgatherd:

	mov eax, 0x80000000
	movd xmm0, eax
	vpbroadcastd ymm0, xmm0
	vmovdqa ymm2, ymmword ptr real_offset[rip]
	vmovdqa ymm1, ymmword ptr cplx_offset[rip]
	mov r9, rcx
	mov r8, rdx
	xor rcx, rcx
	mov r10, rsi
	mov rsi, rdi
	
loop:
	lea r11, [r10+rcx*8]
	vpxor ymm5, ymm5, ymm5
	add rcx, 0x8
	vpxor ymm6, ymm6, ymm6
	vmovdqa ymm3, ymm0
	vmovdqa ymm4, ymm0
	vpgatherdd ymm5, [r11+ymm2*4], ymm3
	vpgatherdd ymm6, [r11+ymm1*4], ymm4
	vmovdqu ymmword ptr [r9], ymm5
	vmovdqu ymmword ptr [r8], ymm6
	add r9, 0x20
	add r8, 0x20
	cmp rcx, rsi
	jl loop

	vzeroupper
	ret

	.data
	.p2align 5

real_offset:
	.quad 0x200000000
	.quad 0x600000004
	.quad 0xA00000008
	.quad 0xD0000000C

cplx_offset:
	.quad 0x300000001
	.quad 0x700000005
	.quad 0xB00000009
	.quad 0xF0000000D

	
