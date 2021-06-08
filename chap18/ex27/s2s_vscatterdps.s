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

	.globl _s2s_vscatterdps
	.globl s2s_vscatterdps

	# void s2s_vscatterdps(uint64_t len, float *imaginary_buffer,
	#                      float *real_buffer, complex_num *complex_buffer);
	#     rdi = len
	#     rsi = imaginary_buffer
	#     rdx = real_buffer
	#     rcx = complex_buffer


	.text

_s2s_vscatterdps:
s2s_vscatterdps:

	vmovaps zmm0, gather_imag_index[rip]
	vmovaps zmm1, gather_real_index[rip]

	mov r10, rdi
	mov r8, rcx
	mov rax, rdx
	mov r9, rsi
	xor rcx, rcx
	xor rsi, rsi

loop:
	vpcmpeqb k1, xmm0, xmm0
	lea r11, [r8+rcx*4]
	vpcmpeqb k2, xmm0, xmm0
	vmovups zmm2, [rax+rsi*4]
	vmovups zmm3, [r9+rsi*4]
	vscatterdps [r11+zmm1*4]{k1}, zmm2
	vscatterdps [r11+zmm0*4]{k2}, zmm3
	add rsi, 0x10
	add rcx, 0x20
	cmp rsi, r10
	jl loop

	vzeroupper

	ret

	.data
	.p2align 6

gather_imag_index:
	.4byte 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31
gather_real_index:
	.4byte 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30
