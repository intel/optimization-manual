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

	.globl _transpose_avx512
	.globl transpose_avx512

	# void transpose_avx512(uint16_t *out, const uint16_t *in)
	# On entry:
	#     rdi = out
	#     rsi = in

	.text

_transpose_avx512:
transpose_avx512:
	lea rax, permMaskBuffer[rip]	# mov rax, permMaskBuffer
	vmovdqa32 zmm10, [rax]
	vmovdqa32 zmm11, [rax+0x40]
					# mov rsi, pImage
					# mov rdi, pOutImage
	xor rdx, rdx
matrix_loop:
	vmovdqa32 zmm2, [rsi]
	vmovdqa32 zmm3, [rsi+0x40]
	vmovdqa32 zmm0, zmm10
	vmovdqa32 zmm1, zmm11
	vpermi2w zmm0, zmm2, zmm3
	vpermi2w zmm1, zmm2, zmm3
	vmovdqa32 [rdi], zmm0
	vmovdqa32 [rdi+0x40], zmm1
	add rdx, 1
	add rsi, 64*2
	add rdi, 64*2
	cmp rdx, 50
	jne matrix_loop

	vzeroupper
	ret

	.data
	.p2align 6

permMaskBuffer:
	.short 0, 8, 16, 24, 32, 40, 48, 56
	.short 1, 9, 17, 25, 33, 41, 49, 57
	.short 2, 10, 18, 26, 34, 42, 50, 58
	.short 3, 11, 19, 27, 35, 43, 51, 59
	.short 4, 12, 20, 28, 36, 44, 52, 60
	.short 5, 13, 21, 29, 37, 45, 53, 61
	.short 6, 14, 22, 30, 38, 46, 54, 62
	.short 7, 15, 23, 31, 39, 47, 55, 63
