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

	.globl _subsum_avx
	.globl subsum_avx

	# void subsum_avx(float *in, float *out, size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_subsum_avx:
subsum_avx:

	push rbx

	mov rax, rdi
	mov rbx, rsi
	xor rcx, rcx

	vxorps ymm0, ymm0, ymm0
	vxorps ymm1, ymm1, ymm1
loop1:
	vmovaps ymm2, [rax+4*rcx]
	vshufps ymm4, ymm0, ymm2, 0x40
	vshufps ymm3, ymm4, ymm2, 0x99
	vshufps ymm5, ymm0, ymm4, 0x80
	vaddps ymm6, ymm2, ymm3
	vaddps ymm7, ymm4, ymm5
	vaddps ymm9, ymm6, ymm7
	vaddps ymm1, ymm9, ymm1
	vshufps ymm8, ymm9, ymm9, 0xff
	vperm2f128 ymm10, ymm8, ymm0, 0x2
	vaddps ymm12, ymm1, ymm10
	vshufps ymm11, ymm12, ymm12, 0xff
	vperm2f128 ymm1, ymm11, ymm11, 0x11
	vmovaps [rbx+4*rcx], ymm12
	add rcx, 8
	cmp rcx, rdx
	jl loop1

	pop rbx
	vzeroupper
	ret
