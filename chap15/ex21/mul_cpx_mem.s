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

	.globl _mul_cpx_mem
	.globl mul_cpx_mem

	# void mul_cpx_mem(complex_num *in1, complex_num *in2, complex_num *out, size_t len);
	# On entry:
	#     rdi = in1
	#     rsi = in2
	#     rdx = out
	#     rcx = len

	.text

_mul_cpx_mem:
mul_cpx_mem:

	push rbx

	mov rax, rdi    # mov rax, inPtr1
	mov rbx, rsi    # mov rbx, inPtr2
	                # mov rdx, outPtr  (rdx already contains the out array)
	mov r8, rcx     # mov r8, len

	xor rcx, rcx

loop1:
	vmovaps ymm0, [rax +8*rcx]
	vmovaps ymm4, [rax +8*rcx +32]
	vmovsldup ymm2, [rbx +8*rcx]
	vmulps ymm2, ymm2, ymm0
	vshufps ymm0, ymm0, ymm0, 177
	vmovshdup ymm1, [rbx +8*rcx]
	vmulps ymm1, ymm1, ymm0
	vmovsldup ymm6, [rbx +8*rcx +32]
	vmulps ymm6, ymm6, ymm4
	vaddsubps ymm3, ymm2, ymm1
	vmovshdup ymm5, [rbx +8*rcx +32]
	vmovaps [rdx +8*rcx], ymm3
	vshufps ymm4, ymm4, ymm4, 177
	vmulps ymm5, ymm5, ymm4
	vaddsubps ymm7, ymm6, ymm5
	vmovaps [rdx +8*rcx +32], ymm7
	add rcx, 8
	cmp rcx, r8
	jl loop1

	vzeroupper
	pop rbx
	ret
