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

	.globl _mul_blend_avx512
	.globl mul_blend_avx512

	# void mul_blend_avx512(double *a, double *b, double *c, size_t N);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = c
	#     rcx = N

	.text

_mul_blend_avx512:
mul_blend_avx512:

	mov rax, rdi        # mov rax, a
	mov r11, rsi        # mov r11, b
	mov r8, rcx         # mov r8, N
	shr r8, 5
	mov rsi, rdx        # mov rsi, c

	xor rcx, rcx
	xor r9, r9
	mov rdi, 1
	cvtsi2sd xmm8, rdi
	vbroadcastsd zmm8, xmm8

loop:
	vmovups zmm0, zmmword ptr[rax+rcx*8]
	inc r9d
	vmovups zmm2, zmmword ptr[rax+rcx*8+0x40]
	vmovups zmm4, zmmword ptr[rax+rcx*8+0x80]
	vmovups zmm6, zmmword ptr[rax+rcx*8+0xc0]
	vmovups zmm1, zmmword ptr[r11+rcx*8]
	vmovups zmm3, zmmword ptr[r11+rcx*8+0x40]
	vmovups zmm5, zmmword ptr[r11+rcx*8+0x80]
	vmovups zmm7, zmmword ptr[r11+rcx*8+0xc0]
	vcmppd k1, zmm8, zmm0, 0x1
	vcmppd k2, zmm8, zmm2, 0x1
	vcmppd k3, zmm8, zmm4, 0x1
	vcmppd k4, zmm8, zmm6, 0x1
	vmulpd zmm1{k1}, zmm0, zmm1
	vmulpd zmm3{k2}, zmm2, zmm3
	vmulpd zmm5{k3}, zmm4, zmm5
	vmulpd zmm7{k4}, zmm6, zmm7
	vmovups zmmword ptr [rsi], zmm1
	vmovups zmmword ptr [rsi+0x40], zmm3
	vmovups zmmword ptr [rsi+0x80], zmm5
	vmovups zmmword ptr [rsi+0xc0], zmm7
	add rcx, 0x20
	add rsi, 0x100
	cmp r9d, r8d
	jb loop

	vzeroupper
	ret
