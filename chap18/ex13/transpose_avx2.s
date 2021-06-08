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

	.globl _transpose_avx2
	.globl transpose_avx2

	# void transpose_avx2(uint16_t *out, const uint16_t *in)
	# On entry:
	#     rdi = out
	#     rsi = in

	.text

_transpose_avx2:
transpose_avx2:

					# mov rsi, pImage
					# mov rdi, pOutImage

	xor rdx, rdx
matrix_loop:
	vmovdqa xmm0, [rsi]
	vmovdqa xmm1, [rsi+0x10]
	vmovdqa xmm2, [rsi+0x20]
	vmovdqa xmm3, [rsi+0x30]
	vinserti128 ymm0, ymm0, [rsi+0x40], 0x1
	vinserti128 ymm1, ymm1, [rsi+0x50], 0x1
	vinserti128 ymm2, ymm2, [rsi+0x60], 0x1
	vinserti128 ymm3, ymm3, [rsi+0x70], 0x1
	vpunpcklwd ymm4, ymm0, ymm1
	vpunpckhwd ymm5, ymm0, ymm1
	vpunpcklwd ymm6, ymm2, ymm3
	vpunpckhwd ymm7, ymm2, ymm3
	vpunpckldq ymm0, ymm4, ymm6
	vpunpckhdq ymm1, ymm4, ymm6
	vpunpckldq ymm2, ymm5, ymm7
	vpunpckhdq ymm3, ymm5, ymm7
	vpermq ymm0, ymm0, 0xD8
	vpermq ymm1, ymm1, 0xD8
	vpermq ymm2, ymm2, 0xD8
	vpermq ymm3, ymm3, 0xD8
	vmovdqa [rdi], ymm0
	vmovdqa [rdi+0x20], ymm1
	vmovdqa [rdi+0x40], ymm2
	vmovdqa [rdi+0x60], ymm3
	add rdx, 1
	add rsi, 64*2
	add rdi, 64*2
	cmp rdx, 50
	jne matrix_loop

	vzeroupper
	ret
