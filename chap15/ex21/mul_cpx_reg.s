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

	.globl _mul_cpx_reg
	.globl mul_cpx_reg

	# void mul_cpx_reg(complex_num *in1, complex_num *in2, complex_num *out, size_t len);
	# On entry:
	#     rdi = in1
	#     rsi = in2
	#     rdx = out
	#     rcx = len

	.text

_mul_cpx_reg:
mul_cpx_reg:

	push rbx

	mov rax, rdi    # mov rax, inPtr1
	mov rbx, rsi    # mov rbx, inPtr2
	                # mov rdx, outPtr  (rdx already contains the out array)
	mov r8, rcx     # mov r8, len

	xor rcx, rcx
loop1:
	vmovaps ymm0, [rax +8*rcx]
	vmovaps ymm4, [rax +8*rcx +32]
	vmovaps ymm3, [rbx +8*rcx]
	vmovsldup ymm2, ymm3
	vmulps ymm2, ymm2, ymm0
	vshufps ymm0, ymm0, ymm0, 177
	vmovshdup ymm1, ymm3
	vmulps ymm1, ymm1, ymm0
	vmovaps ymm7, [rbx +8*rcx +32]
	vmovsldup ymm6, ymm7
	vmulps ymm6, ymm6, ymm4
	vaddsubps ymm2, ymm2, ymm1
	vmovshdup ymm5, ymm7
	vmovaps [rdx+8*rcx], ymm2
	vshufps ymm4, ymm4, ymm4, 177
	vmulps ymm5, ymm5, ymm4
	vaddsubps ymm6, ymm6, ymm5
	vmovaps [rdx+8*rcx+32], ymm6
	add rcx, 8
	cmp rcx, r8
	jl loop1

	vzeroupper
	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
