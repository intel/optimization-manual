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

	.globl _double_sqrt_26
	.globl double_sqrt_26

	# void double_sqrt_26(double *a, double *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_double_sqrt_26:
double_sqrt_26:

	vmovupd zmm0, [rdi]

	vrsqrt14pd zmm1, zmm0
	vfpclasspd k2, zmm0, 0xe		# vfpclasspd k2, zmm0, 0eh
	knotw k3, k2
	vmulpd zmm0 {k3}, zmm0, zmm1
	vmulpd zmm1, zmm1, half[rip]		# vmulpd zmm1, zmm1, ZMMWORD PTR [OneHalf]
	vfnmadd213pd zmm1, zmm0, half[rip]	# vfnmadd213pd zmm1, zmm0, ZMMWORD PTR [OneHalf]
	vfmadd213pd zmm0 {k3}, zmm1, zmm0

	vmovupd [rsi], zmm0

	vzeroupper

	ret

	.data
	.p2align 6

half:
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
