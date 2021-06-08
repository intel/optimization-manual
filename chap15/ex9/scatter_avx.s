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

	.globl _scatter_avx
	.globl scatter_avx

	# void scatter_avx(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = index
	#     rcx = len

	.text
_scatter_avx:
scatter_avx:

	push rbx

	# registers are already initialised correctly.
	# mov rdi, InBuf
	# mov rsi, OutBuf
	# mov rdx, Index
	mov r8, rcx

	xor rcx, rcx
loop1:
	vmovaps ymm0, [rdi + 4*rcx]
	movsxd rax, [rdx + 4*rcx]
	movsxd rbx, [rdx + 4*rcx + 4]
	vmovss [rsi + 4*rax], xmm0
	movsxd rax, [rdx + 4*rcx + 8]
	vpalignr xmm1, xmm0, xmm0, 4

	vmovss [rsi + 4*rbx], xmm1
	movsxd rbx, [rdx + 4*rcx + 12]
	vpalignr xmm2, xmm0, xmm0, 8
	vmovss [rsi + 4*rax], xmm2
	movsxd rax, [rdx + 4*rcx + 16]
	vpalignr xmm3, xmm0, xmm0, 12
	vmovss [rsi + 4*rbx], xmm3
	movsxd rbx, [rdx + 4*rcx + 20]
	vextractf128 xmm0, ymm0, 1
	vmovss [rsi + 4*rax], xmm0
	movsxd rax, [rdx + 4*rcx + 24]
	vpalignr xmm1, xmm0, xmm0, 4
	vmovss [rsi + 4*rbx], xmm1
	movsxd rbx, [rdx + 4*rcx + 28]
	vpalignr xmm2, xmm0, xmm0, 8
	vmovss [rsi + 4*rax], xmm2
	vpalignr xmm3, xmm0, xmm0, 12
	vmovss [rsi + 4*rbx], xmm3
	add rcx, 8
	cmp rcx, r8
	jl loop1

	vzeroupper
	pop rbx
	ret
