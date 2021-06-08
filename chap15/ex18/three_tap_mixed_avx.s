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

	.globl _three_tap_mixed_avx
	.globl three_tap_mixed_avx

	# void three_tap_mixed_avx(float *a, float *coeff, float *out, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = coeff
	#     rdx = out
	#     rcx = len

	.text

_three_tap_mixed_avx:
three_tap_mixed_avx:

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
	vmovaps xmm3, [rdi]                # xmm3={A[n+3],A[n+2],A[n+1],A[n]}
loop_start:
	vmovaps xmm4, [rdi+16]             # xmm4={A[n+7],A[n+6],A[n+5],A[n+4]}
	vmovaps xmm5, [rdi+32]             # xmm5={A[n+11], A[n+10],A[n+9],A[n+8]}
	vinsertf128 ymm3, ymm3, xmm4, 1    # ymm3={A[n+7],A[n+6],A[n+5],A[n+4];
	                                   #  A[n+3], A[n+2],A[n+1],A[n]}
	vpalignr xmm6, xmm4, xmm3, 4       # xmm6={A[n+4],A[n+3],A[n+2],A[n+1]}
	vpalignr xmm7, xmm5, xmm4, 4 	   # xmm7={A[n+8],A[n+7],A[n+6],A[n+5]}
	vinsertf128 ymm6, ymm6, xmm7, 1    # ymm6={A[n+8],A[n+7],A[n+6],A[n+5];
	                                   #  A[n+4],A[n+3],A[n+2],A[n+1]}
	vpalignr xmm8, xmm4, xmm3, 8       # xmm8={A[n+5],A[n+4],A[n+3],A[n+2]}
	vpalignr xmm9, xmm5, xmm4, 8       # xmm9={A[n+9],A[n+8],A[n+7],A[n+6]}
	vinsertf128 ymm8, ymm8, xmm9, 1    # ymm8={A[n+9],A[n+8],A[n+7],A[n+6];
	                                   #  A[n+5],A[n+4],A[n+3],A[n+2]}
	vmulps ymm3, ymm3, ymm2            # ymm3={C0*A[n+7],C0*A[n+6],C0*A[n+5], C0*A[n+4];
	                                   #  C0*A[n+3],C0*A[n+2],C0*A[n+1],C0*A[n]}
	vmulps ymm6, ymm6, ymm1            # ymm6={C1*A[n+8],C1*A[n+7],C1*A[n+6],C1*A[n+5];
                                           #  C1*A[n+4],C1*A[n+3],C1*A[n+2],C1*A[n+1]}
	vmulps ymm8, ymm8, ymm0            # ymm8={C2*A[n+9],C2*A[n+8],C2*A[n+7],C2*A[n+6];
	                                   #  C2*A[n+5],C2*A[n+4],C2*A[n+3],C2*A[n+2]}
	vaddps ymm3, ymm3, ymm6
	vaddps ymm3, ymm3, ymm8
	vmovaps [rsi], ymm3
	vmovaps xmm3, xmm5
	add rdi, 32                        # inPtr+=32
	add rbx, 8                         # loop counter
	add rsi, 32                        # outPtr+=32
	cmp rbx, rcx
	jl loop_start

	vzeroupper
	pop r15
	pop rbx
	ret
