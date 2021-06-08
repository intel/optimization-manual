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

	.globl _avx2_gatherpd
	.globl avx2_gatherpd

	# void avx2_gatherpd(size_t len, uint32_t* index_buffer, double* imaginary_buffer,
	#                    double* real_buffer, complex_num* complex_buffer);
	# On entry:
	#     rdi = len (length in elements of )
	#     rsi = index_buffer
	#     rdx = imaginary_buffer
	#     rcx = real_buffer
	#     r8  = complex_buffer

	.text

_avx2_gatherpd:
avx2_gatherpd:

	mov eax, 0x80000000
	movd xmm0, eax
	mov eax, 1
	movd xmm13, eax
	vpbroadcastd ymm13, xmm13
	vpbroadcastd ymm0, xmm0
	mov rax, rdx
	mov r11, rdi
	xor rdx, rdx

loop:
	vmovdqu ymm1, ymmword ptr [rsi+rdx*4]
	vpaddd ymm3, ymm1, ymm1
	vpaddd ymm14, ymm13, ymm3
	vxorpd ymm5, ymm5, ymm5
	vmovdqa ymm2, ymm0
	vxorpd ymm6, ymm6, ymm6
	vmovdqa ymm4, ymm0
	vxorpd ymm10, ymm10, ymm10
	vmovdqa ymm7, ymm0
	vxorpd ymm11, ymm11, ymm11
	vmovdqa ymm9, ymm0
	vextracti128 xmm12, ymm14, 0x1
	vextracti128 xmm8, ymm3, 0x1
	vgatherdpd ymm6, [r8+xmm8*8], ymm4
	vgatherdpd ymm5, [r8+xmm3*8], ymm2
	vmovupd ymmword ptr [rcx+rdx*8], ymm5
	vmovupd ymmword ptr [rcx+rdx*8+0x20], ymm6
	vgatherdpd ymm11, [r8+xmm12*8], ymm7
	vgatherdpd ymm10, [r8+xmm14*8], ymm9
	vmovupd ymmword ptr [rax+rdx*8], ymm10
	vmovupd ymmword ptr [rax+rdx*8+0x20], ymm11
	add rdx, 0x8
	cmp rdx, r11
	jb loop

	vzeroupper
	ret
