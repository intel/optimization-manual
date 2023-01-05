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

	.globl _rsqrtps_newt_sse
	.globl rsqrtps_newt_sse

	# void rsqrtps_newt_sse(float *in, float *out, size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_rsqrtps_newt_sse:
rsqrtps_newt_sse:

	push rbx
	
	mov rax, rdi
	mov rbx, rsi
	mov rcx, rdx
	shl rcx, 2    # rcx is size of inputs in bytes
	xor rdx, rdx

	movups xmm3, three[rip]
	movups xmm4, minus_half[rip]
loop1:
	movups xmm5, [rax+rdx]
	rsqrtps xmm0, xmm5
	movaps xmm2, xmm0
	mulps xmm0, xmm0
	mulps xmm0, xmm5
	subps xmm0, xmm3
	mulps xmm0, xmm2
	mulps xmm0, xmm4
	movups [rbx+rdx], xmm0
	add rdx, 16
	cmp rdx, rcx
	jl loop1
	pop rbx
	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 4

minus_half:
	.float -0.5, -0.5, -0.5, -0.5

three:
	.float 3.0, 3.0, 3.0, 3.0

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
