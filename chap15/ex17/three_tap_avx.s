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

	.globl _three_tap_avx
	.globl three_tap_avx

	# void three_tap_avx(float *a, float *coeff, float *out, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = coeff
	#     rdx = out
	#     rcx = len

	.text

_three_tap_avx:
three_tap_avx:

	push rbx
	push r15

	xor ebx, ebx

			                   # mov rdi, inPtr  (rdi already contains in)
	mov r15, rsi                       # mov r15, coeffs
	mov rsi, rdx                       # mov rsi, outPtr
			                   # mov rcx, len ( rcx already contains len )

	vbroadcastss ymm2, [r15]           # load and broadcast coeff 0
	vbroadcastss ymm1, [r15+4]         # load and broadcast coeff 1
	vbroadcastss ymm0, [r15+8]         # load and broadcast coeff 2

loop_start:
	vmovaps ymm5, [rdi]                # Ymm5={A[n+7],A[n+6],A[n+5],A[n+4];
	                                   #  A[n+3],A[n+2],A[n+1] , A[n]}
	vshufps ymm6, ymm5, [rdi+16], 0x4e # ymm6={A[n+9],A[n+8],A[n+7],A[n+6];
	                                   #  A[n+5],A[n+4],A[n+3],A[n+2]}
	vshufps ymm7, ymm5, ymm6, 0x99     # ymm7={A[n+8],A[n+7],A[n+6],A[n+5];
	                                   #  A[n+4],A[n+3],A[n+2],A[n+1]}
	vmulps ymm3, ymm5, ymm2            # ymm3={C0*A[n+7],C0*A[n+6],C0*A[n+5],C0*A[n+4];
	                                   #  C0*A[n+3],C0*A[n+2],C0*A[n+1],C0*A[n]}
	vmulps ymm9, ymm7, ymm1            # ymm9={C1*A[n+8],C1*A[n+7],C1*A[n+6],C1*A[n+5];
	                                   #  C1*A[n+4],C1*A[n+3],C1*A[n+2],C1*A[n+1]}
	vmulps ymm4, ymm6, ymm0            # ymm4={C2*A[n+9],C2*A[n+8],C2*A[n+7],C2*A[n+6];
	                                   #  C2*A[n+5],C2*A[n+4],C2*A[n+3],C2*A[n+2]}
	vaddps ymm8, ymm3, ymm4
	vaddps ymm10, ymm8, ymm9
	vmovaps [rsi], ymm10
	add rdi, 32                        # inPtr+=32
	add rbx, 8                         # loop counter
	add rsi, 32                        # outPtr+=32
	cmp rbx, rcx
	jl loop_start
 
	vzeroupper
	pop r15
	pop rbx
	ret
