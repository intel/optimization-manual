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

	.globl _three_tap_sse
	.globl three_tap_sse

	# void three_tap_sse(float *a, float *coeff, float *out, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = coeff
	#     rdx = out
	#     rcx = len

	.text

_three_tap_sse:
three_tap_sse:

	push rbx
	push r15

			      # mov rdi, inPtr  (rdi already contains in)
	mov r15, rsi          # mov r15, coeffs
	mov rsi, rdx          # mov rsi, outPtr
			      # mov rcx, len ( rcx already contains len )
	xor ebx, ebx
	movss xmm2, [r15]     # load coeff 0
	shufps xmm2, xmm2, 0  # broadcast coeff 0
	movss xmm1, [r15+4]   # load coeff 1
	shufps xmm1, xmm1, 0  # broadcast coeff 1
	movss xmm0, [r15+8]   # coeff 2
	shufps xmm0, xmm0, 0  # broadcast coeff 2
	movaps xmm5, [rdi]    # xmm5={A[n+3],A[n+2],A[n+1],A[n]}

loop_start:
	movaps xmm6, [rdi+16] # xmm6={A[n+7],A[n+6],A[n+5],A[n+4]}
	movaps xmm7, xmm6
	movaps xmm8, xmm6
	add rdi, 16           # inPtr+=16
	add rbx, 4            # loop counter
	palignr xmm7, xmm5, 4 # xmm7={A[n+4],A[n+3],A[n+2],A[n+1]}
	palignr xmm8, xmm5, 8 # xmm8={A[n+5],A[n+4],A[n+3],A[n+2]}
	mulps xmm5, xmm2      # xmm5={C0*A[n+3],C0*A[n+2],C0*A[n+1], C0*A[n]}
	mulps xmm7, xmm1      # xmm7={C1*A[n+4],C1*A[n+3],C1*A[n+2],C1*A[n+1]}
	mulps xmm8, xmm0      # xmm8={C2*A[n+5],C2*A[n+4] C2*A[n+3],C2*A[n+2]}
	addps xmm7, xmm5
	addps xmm7, xmm8
	movaps [rsi], xmm7
	movaps xmm5, xmm6
	add rsi, 16           # outPtr+=16
	cmp rbx, rcx
	jl loop_start

	pop r15
	pop rbx
	ret
