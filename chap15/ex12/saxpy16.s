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
	
	.globl _saxpy16
	.globl saxpy16

	# void saxpy16(float* src, float *src2, size_t len, float *dst, float alpha);
	# On entry:
	#     rdi = src
	#     rsi = src2
	#     rdx = len (length in bytes of all three arrays)
	#     rcx = dst
	#     xmm0 = alpha
	
	.text
_saxpy16:
saxpy16:
	push rbx

	mov rax, rdi
	mov rbx, rsi
	xor rdi, rdi
	vbroadcastss ymm0, xmm0

start_loop:

	vmovups xmm2, [rax+rdi]
	vinsertf128 ymm2, ymm2, [rax+rdi+16], 1
	vmulps ymm1, ymm0, ymm2
	vmovups xmm2, [ rbx + rdi]
	vinsertf128 ymm2, ymm2, [rbx+rdi+16], 1
	vaddps ymm1, ymm1, ymm2
	vmovups [rcx+rdi], ymm1
	vmovups xmm2, [rax+rdi+32]
	vinsertf128 ymm2, ymm2, [rax+rdi+48], 1
	vmulps ymm1, ymm0, ymm2
	vmovups xmm2, [rbx+rdi+32]
	vinsertf128 ymm2, ymm2, [rbx+rdi+48], 1
	vaddps ymm1, ymm1, ymm2
	vmovups [rcx+rdi+32], ymm1
	add rdi, 64
	cmp rdi, rdx
	jl start_loop

	vzeroupper
	pop rbx
	ret
