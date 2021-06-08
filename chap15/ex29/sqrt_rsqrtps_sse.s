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

	.globl _sqrt_rsqrtps_sse
	.globl sqrt_rsqrtps_sse

	# void sqrt_rsqrtps_sse(float *in, float *out, size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_sqrt_rsqrtps_sse:
sqrt_rsqrtps_sse:

	push rbx

	mov rax, rdi
	mov rbx, rsi
	mov rcx, rdx
	shl rcx, 2    # rcx is size of inputs in bytes
	xor rdx, rdx

loop1:
	movups xmm1, [rax+rdx]
	xorps xmm8, xmm8
	cmpneqps xmm8, xmm1
	rsqrtps xmm1, xmm1
	rcpps xmm1, xmm1
	andps xmm1, xmm8
	movups [rbx+rdx], xmm1
	add rdx, 16
	cmp rdx, rcx
	jl loop1

	pop rbx
	ret
