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

	.globl _g2s_vpgatherdd
	.globl g2s_vpgatherdd

	# void g2s_vpgatherdd(uint32_t len, complex_num *complex_buffer,
	#	              float *imaginary_buffer, float *real_buffer);
	#     edi = len
	#     rsi = complex_buffer
	#     rdx = imaginary_buffer
	#     rcx = real_buffer


	.text

_g2s_vpgatherdd:
g2s_vpgatherdd:

	vmovaps zmm0, gather_imag_index[rip]
	vmovaps zmm1, gather_real_index[rip]

	push r14

	mov r8, rsi
	mov r14d, edi
	shr r14d, 5
	mov r9, rcx
	mov rcx, rdx
	xor edx, edx
	xor esi, esi

loop:
	vpcmpeqb k1, xmm0, xmm0
	vpcmpeqb k2, xmm0, xmm0
	movsxd rdx, edx
	movsxd rdi, esi
	inc esi
	shl rdi, 0x7
	vpxord zmm2, zmm2, zmm2
	lea rax, [r8+rdx*8]
	add edx, 0x20
	vpgatherdd zmm2{k1}, [rax+zmm1*4]
	vpxord zmm3, zmm3, zmm3
	vpxord zmm4, zmm4, zmm4
	vpxord zmm5, zmm5, zmm5
	vpgatherdd zmm3{k2}, [rax+zmm0*4]
	vpcmpeqb k3, xmm0, xmm0
	vpcmpeqb k4, xmm0, xmm0
	vmovups [r9+rdi*1], zmm2
	vmovups [rcx+rdi*1], zmm3
	vpgatherdd zmm4{k3}, [rax+zmm1*4+0x80]
	vpgatherdd zmm5{k4}, [rax+zmm0*4+0x80]
	vmovups [r9+rdi*1+0x40], zmm4
	vmovups [rcx+rdi*1+0x40], zmm5
	cmp esi, r14d
	jb loop

	vzeroupper

	pop r14

	ret

	.data
	.p2align 6

gather_imag_index:
	.4byte 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31
gather_real_index:
	.4byte 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
