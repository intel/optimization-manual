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

	.globl _fp_mul_add
	.globl fp_mul_add

	# void fp_mul_add(float *a, float *c1, float *c2, uint32_t iters)
	# On entry:
	#     rdi = a
	#     rsi = c1
	#     rdx = c2
	#     ecx = iters

	.text

_fp_mul_add:
fp_mul_add:

	push rbx

	mov eax, ecx
	mov rbx, rdi
	mov rcx, rsi

	vmovups ymm0, ymmword ptr [rbx] # A
	vmovups ymm1, ymmword ptr [rcx] # C1
	vmovups ymm2, ymmword ptr [rdx] # C2
loop:
	vmulps ymm4, ymm0 ,ymm2 # A * C2
	vaddps ymm0, ymm1, ymm4
	dec eax
	jnz loop
	vmovups ymmword ptr[rbx], ymm0 # store A

	pop rbx
	vzeroupper
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
