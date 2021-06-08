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

	.globl _saxpy32
	.globl saxpy32

	# void saxpy32(float* src, float *src2, size_t len, float *dst, float alpha);
	# On entry:
	#     rdi = src
	#     rsi = src2
	#     rdx = len (length in bytes of all three arrays)
	#     rcx = dst
	#     xmm0 = alpha

	.text
_saxpy32:
saxpy32:
	push rbx

	mov rax, rdi
	mov rbx, rsi
	xor rdi, rdi
	vbroadcastss ymm0, xmm0

start_loop:
	vmovups ymm1, [rax+rdi]
	vmulps ymm1, ymm1, ymm0
	vmovups ymm2, [rbx+rdi]
	vaddps ymm1, ymm1, ymm2
	vmovups [rcx+rdi], ymm1
	vmovups ymm1, [rax+rdi+32]
	vmulps ymm1, ymm1, ymm0
	vmovups ymm2, [rbx+rdi+32]
	vaddps ymm1, ymm1, ymm2
	vmovups [rcx+rdi+32], ymm1
	add rdi, 64
	cmp rdi, rdx
	jl start_loop

	vzeroupper
	pop rbx
	ret
