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

	.globl _poly_avx_256
	.globl poly_avx_256

	# void poly_avx_256(float *in, float *out, int32_t len);
	# On entry:
	#     rdi = in
	#     rsi = out
	#     edx = len

	.text
_poly_avx_256:
poly_avx_256:

	push rbx

	mov rax, rdi   # mov rax, pA
	mov rbx, rsi   # mov rbx, pB
	movsxd r8, edx # movsxd r8, len
	sub r8, 8
loop1:
	# Load A
	vmovups ymm0, [rax+r8*4]
	# A^2
	vmulps ymm1, ymm0, ymm0
	# A^3
	vmulps ymm2, ymm1, ymm0
	# A+A^2
	vaddps ymm0, ymm0, ymm1
	# A+A^2+A^3
	vaddps ymm0, ymm0, ymm2
	# Store result
	vmovups [rbx+r8*4], ymm0
	sub r8, 8
	jge loop1

	vzeroupper
	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
