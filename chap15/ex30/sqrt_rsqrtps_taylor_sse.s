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

	.globl _sqrt_rsqrtps_taylor_sse
	.globl sqrt_rsqrtps_taylor_sse

	# void sqrt_rsqrtps_taylor_sse(float *in, float *out, size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_sqrt_rsqrtps_taylor_sse:
sqrt_rsqrtps_taylor_sse:

	push rbx

	mov rax, rdi
	mov rbx, rsi
	mov rcx, rdx
	shl rcx, 2    # rcx is size of inputs in bytes
	xor rdx, rdx

	movups xmm6, three[rip]
	movups xmm7, minus_half[rip]

loop1:
	movups xmm3, [rax+rdx]
	rsqrtps xmm1, xmm3
	xorps xmm8, xmm8
	cmpneqps xmm8, xmm3
	andps xmm1, xmm8
	movaps xmm4, xmm1
	mulps xmm1, xmm3
	movaps xmm5, xmm1
	mulps xmm1, xmm4
	subps xmm1, xmm6
	mulps xmm1, xmm5
	mulps xmm1, xmm7
	movups [rbx+rdx], xmm1
	add rdx, 16
	cmp rdx, rcx
	jl loop1

	pop rbx
	ret

	.data
	.p2align 4

minus_half:
	.float -0.5, -0.5, -0.5, -0.5

three:
	.float 3.0, 3.0, 3.0, 3.0

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
