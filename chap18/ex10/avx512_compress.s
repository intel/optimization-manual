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

	.globl _avx512_compress
	.globl avx512_compress

	# uint64_t avx512_compress(uint32_t *out, const uint32_t *in, uint64_t len)
	# On entry:
	#     rdi = out
	#     rsi = in
	#     rdx = len

	# On exit
	#     rax = out_len

	.text

_avx512_compress:
avx512_compress:

	push r12

	                                   # mov rsi, source
	                                   # mov rdi, dest
	mov r9, rdx                        # mov r9, len
	xor r8, r8
	xor r10, r10
	vpxord zmm0, zmm0, zmm0

mainloop:
	vmovdqa32 zmm1, [rsi+r8*4]
	vpcmpgtd k1, zmm1, zmm0
	vpcompressd zmm2 {k1}, zmm1
	vmovdqu32 [rdi+r10*4], zmm2
	kmovd r11d, k1
	popcnt r12, r11
	add r8, 16
	add r10, r12
	cmp r8, r9
	jne mainloop

	mov rax, r10

	pop r12

	vzeroupper
	ret
