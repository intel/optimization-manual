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

	.globl _fma_shuffle_tpt
	.globl fma_shuffle_tpt

	# void fma_shuffle_tpt(uint64_t loop_cnt);
	# On entry:
	#     rdi = loop_cnt

	.text

_fma_shuffle_tpt:
fma_shuffle_tpt:

	vmovups zmm0, one_vec[rip]
	vmovups zmm1, one_vec[rip]
	vmovups zmm2, one_vec[rip]
	vmovups zmm3, one_vec[rip]
	vmovups zmm4, one_vec[rip]
	vmovups zmm5, one_vec[rip]
	vmovups zmm6, one_vec[rip]
	vmovups zmm7, one_vec[rip]
	vmovups zmm8, one_vec[rip]
	vmovups zmm9, one_vec[rip]
	vmovups zmm10, one_vec[rip]
	vmovups zmm11, one_vec[rip]
	vmovups zmm12, shuf_vec[rip]
	vmovups zmm13, shuf_vec[rip]
	vmovups zmm14, shuf_vec[rip]
	vmovups zmm15, shuf_vec[rip]
	vmovups zmm16, shuf_vec[rip]
	vmovups zmm17, shuf_vec[rip]
	vmovups zmm18, shuf_vec[rip]
	vmovups zmm19, shuf_vec[rip]
	vmovups zmm20, shuf_vec[rip]
	vmovups zmm21, shuf_vec[rip]
	vmovups zmm22, shuf_vec[rip]
	vmovups zmm23, shuf_vec[rip]
	vmovups zmm30, shuf_vec[rip]
	mov rdx, rdi			# mov rdx, loops
loop1:
	vfmadd231pd zmm0, zmm0, zmm0
	vfmadd231pd zmm1, zmm1, zmm1
	vfmadd231pd zmm2, zmm2, zmm2
	vfmadd231pd zmm3, zmm3, zmm3
	vfmadd231pd zmm4, zmm4, zmm4
	vfmadd231pd zmm5, zmm5, zmm5
	vfmadd231pd zmm6, zmm6, zmm6
	vfmadd231pd zmm7, zmm7, zmm7
	vfmadd231pd zmm8, zmm8, zmm8
	vfmadd231pd zmm9, zmm9, zmm9
	vfmadd231pd zmm10, zmm10, zmm10
	vfmadd231pd zmm11, zmm11, zmm11
	vpermd zmm12, zmm30, zmm30
	vpermd zmm13, zmm30, zmm30
	vpermd zmm14, zmm30, zmm30
	vpermd zmm15, zmm30, zmm30
	vpermd zmm16, zmm30, zmm30
	vpermd zmm17, zmm30, zmm30
	vpermd zmm18, zmm30, zmm30
	vpermd zmm19, zmm30, zmm30
	vpermd zmm20, zmm30, zmm30
	vpermd zmm21, zmm30, zmm30
	vpermd zmm22, zmm30, zmm30
	vpermd zmm23, zmm30, zmm30
	dec rdx
	jg loop1

	vzeroupper

	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 6
one_vec:
	.double 1, 1, 1, 1, 1, 1, 1, 1
shuf_vec:
	.4byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
