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

	.globl _complex_conv_sse
	.globl complex_conv_sse

	# void complex_conv_sse(complex_num *complex_buffer, float *real_buffer, float *imaginary_buffer, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = out1
	#     rdx = out2
	#     rcx = len

	.text
_complex_conv_sse:
complex_conv_sse:

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
	movups xmm0, [rdi+rbx] # i1 r1 i0 r0
	movups xmm1, [rdi+rbx+16] #  i3 r3 i2 r2
	movups xmm2, xmm0
	shufps xmm0, xmm1, 0xdd # i3 i2 i1 i0
	shufps xmm2, xmm1, 0x88	# r3 r2 r1 r0
	movups [rax+rdx], xmm0
	movups [rsi+rdx], xmm2
	add rdx, 16
	add rbx, 32
	cmp rcx, rbx
	jnz loop1

	pop rbx
	ret
