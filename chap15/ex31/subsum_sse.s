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

	.globl _subsum_sse
	.globl subsum_sse

	# void subsum_sse(float *in, float *out, size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_subsum_sse:
subsum_sse:

	push rbx

	mov rax, rdi
	mov rbx, rsi
	xor rcx, rcx

	xor rcx, rcx
	xorps xmm0, xmm0
loop1:
	movaps xmm2, [rax+4*rcx]
	movaps xmm3, xmm2
	movaps xmm4, xmm2
	movaps xmm5, xmm2
	pslldq xmm3, 4
	pslldq xmm4, 8
	pslldq xmm5, 12
	addps xmm2, xmm3
	addps xmm4, xmm5
	addps xmm2, xmm4
	addps xmm2, xmm0
	movaps xmm0, xmm2
	shufps xmm0, xmm2, 0xFF
	movaps [rbx+4*rcx], xmm2
	add rcx, 4
	cmp rcx, rdx
	jl loop1

	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
