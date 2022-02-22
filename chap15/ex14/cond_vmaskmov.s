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

	.globl _cond_vmaskmov
	.globl cond_vmaskmov

	# void cond_vmaskmov(float *a, float *b, float *d, float *c, float *e, size_t len);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = d
	#     rcx = c
	#     r8 = e
	#     r9 = len
	.text

_cond_vmaskmov:
cond_vmaskmov:
	push rbx

	mov rax, rdi            # mov rax, pA
	mov rbx, rsi            # mov rbx, pB
	                        # mov rcx, pC
	                        # mov rdx, pD
	mov rsi, r8             # mov rsi, pE
	mov r8, r9              # mov r8, len
	shl r8, 2               # each element occupies 4 bytes

	# ymm8 all zeros
	vxorps ymm8, ymm8, ymm8
	#  ymm9 all ones
	vcmpps ymm9, ymm8, ymm8, 0
	xor r9, r9
loop1:
	vmovups ymm1, [rax+r9]
	vcmpps ymm2, ymm8, ymm1, 1
	vmaskmovps ymm4, ymm2, [rcx+r9]
	vxorps ymm2, ymm2, ymm9
	vmaskmovps ymm5, ymm2, [rdx+r9]
	vorps ymm4, ymm4, ymm5
	vmulps ymm4, ymm4, [rsi+r9]
	vmovups [rbx+r9], ymm4
	add r9, 32
	cmp r9, r8
	jl loop1

	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
