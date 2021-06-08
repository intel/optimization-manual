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

	.globl _expand_avx512
	.globl expand_avx512

	# void expand_avx512(int32_t *out, int32_t *in, size_t N);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = N

	.text

_expand_avx512:
expand_avx512:

	push r12

					# mov rsi, input
					# mov rdi, output
	mov r9, rdx			# mov r9, len
	xor r8, r8
	xor r10, r10

	vpxord zmm0, zmm0, zmm0
mainloop:
	vmovdqa32 zmm1, [rsi+r8*4]
	vpcmpgtd k1, zmm1, zmm0
	vmovdqu32 zmm1, [rsi+r10*4]
	vpexpandd zmm2 {k1}{z}, zmm1
	vmovdqu32 [rdi+r8*4], zmm2
	add r8, 16
	kmovd r11d, k1
	popcnt r12, r11
	add r10, r12
	cmp r8, r9
	jne mainloop

	pop r12

	vzeroupper
	ret
