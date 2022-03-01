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

	.globl _complex_conv_avx_stride
	.globl complex_conv_avx_stride

	# void complex_conv_avx_stride(complex_num *complex_buffer, float *real_buffer, float *imaginary_buffer, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = out1
	#     rdx = out2
	#     rcx = len

	.text
_complex_conv_avx_stride:
complex_conv_avx_stride:

	push rbx

	xor rbx, rbx
	mov rax, rdx #	mov rax, outPtr2
	xor rdx, rdx

	# rdi and rsi are already initialised correctly.
	# rcx needs to be multiplied by 8
	# mov rcx, len
	shl rcx, 3
	# mov rdi, inPtr
	# mov rsi, outPtr1
loop1:
	vmovups xmm0, [rdi+rbx] # i1 r1 i0 r0
	vmovups xmm1, [rdi+rbx+16] # i3 r3 i2 r2
	vinsertf128 ymm0, ymm0, [rdi+rbx+32] , 1 # i5 r5 i4 r4; i1 r1 i0 r0
	vinsertf128 ymm1, ymm1, [rdi+rbx+48] , 1 # i7 r7 i6 r6; i3 r3 i2 r2
	vshufps ymm2, ymm0, ymm1, 0xdd # i7 i6 i5 i4; i3 i2 i1 i0
	vshufps ymm3, ymm0, ymm1, 0x88 # r7 r6 r5 r4; r3 r2 r1 r0
	vmovups [rax+rdx], ymm2
	vmovups [rsi+rdx], ymm3
	add rdx, 32
	add rbx, 64
	cmp rcx, rbx
	jnz loop1

	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
