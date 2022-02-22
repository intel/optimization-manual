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

	.globl _double_div_26
	.globl double_div_26

	# void double_div_26(double *a, double *b, double *out);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = out

	.text

_double_div_26:
double_div_26:

	vmovupd zmm0, [rdi]
	vmovupd zmm1, [rsi]

	vrcp14pd zmm2, zmm1
	vmulpd zmm3, zmm0, zmm2
	vmovapd zmm4, zmm0
	vfnmadd231pd zmm4, zmm3, zmm1
	vfmadd231pd zmm3, zmm4, zmm2


	vmovupd [rdx], zmm3

	vzeroupper

	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
