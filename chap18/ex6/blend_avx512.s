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

	.globl _blend_avx512
	.globl blend_avx512

	# void blend_avx512(uint32_t *a, uint32_t *b, uint32_t *c, size_t N);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = c
	#     rcx = N

	.text

_blend_avx512:
blend_avx512:

	push rbx

	mov r8, rcx

	mov rax, rdi              # mov rax, pImage
	mov rbx, rsi              # mov rbx, pImage1
	mov rcx, rdx              # mov rcx, pOutImage
	mov rdx, r8               # mov rdx, len

	vpxord zmm0, zmm0, zmm0
mainloop:
	vmovdqa32 zmm2, [rax+rdx*4-0x40]
	vmovdqa32 zmm1, [rbx+rdx*4-0x40]
	vpcmpgtd k1, zmm1, zmm0
	vmovdqa32 zmm3, zmm2
	vpslld zmm2, zmm2, 1
	vpsrld zmm3, zmm3, 1
	vmovdqa32 zmm3 {k1}, zmm2
	vmovdqa32 [rcx+rdx*4-0x40], zmm3
	sub rdx, 16
	jne mainloop

	pop rbx
	vzeroupper
	ret
