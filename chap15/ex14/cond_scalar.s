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

	.globl _cond_scalar
	.globl cond_scalar

	# void cond_scalar(float *a, float *b, float *d, float *c, float *e, size_t len);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = d
	#     rcx = c
	#     r8 = e
	#     r9 = len
	.text

_cond_scalar:
cond_scalar:
	push rbx

	mov rax, rdi            # mov rax, pA
	mov rbx, rsi            # mov rbx, pB
	                        # mov rcx, pC
	                        # mov rdx, pD
	mov rsi, r8             # mov rsi, pE
	mov r8, r9              # mov r8, len
	shl r8, 2               # each element occupies 4 bytes

	# xmm8 all zeros
	vxorps xmm8, xmm8, xmm8
	xor r9, r9
loop1:
	vmovss xmm1, [rax+r9]
	vcomiss xmm1, xmm8
	jbe a_le
a_gt:
	vmovss xmm4, [rcx+r9]
	jmp mul
a_le:
	vmovss xmm4, [rdx+r9]
mul:
	vmulss xmm4, xmm4, [rsi+r9]
	vmovss [rbx+r9], xmm4
	add r9, 4
	cmp r9, r8
	jl loop1

	pop rbx
	ret
