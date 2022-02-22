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

	.globl _double_rsqrt_26
	.globl double_rsqrt_26

	# void double_rsqrt_26(double *a, double *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_double_rsqrt_26:
double_rsqrt_26:

	vmovupd zmm0, [rdi]

	vrsqrt14pd zmm1, zmm0
	vmulpd zmm0, zmm0, zmm1
	vbroadcastsd zmm3, half[rip]			# vbroadcastsd zmm3, half
	vmulpd zmm2, zmm1, zmm3
	vfnmadd213pd zmm2, zmm0, zmm3
	vfmadd213pd zmm1, zmm2, zmm1

	vmovupd [rsi], zmm1

	vzeroupper

	ret

	.data
	.p2align 3

half:	.double 0.5

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
