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

	.globl _single_div_24
	.globl single_div_24

	# void single_div_24(float a, float b, float *out);
	# On entry: 
	#     xmm0 = a
	#     xmm1 = b
	#     rdi = out

	.text

_single_div_24:
single_div_24:

	vbroadcastss zmm0, xmm0		# fill zmm0 with 16 elements of a
	vbroadcastss zmm1, xmm1		# fill zmm1 with 16 elements of b
	vdivps zmm2, zmm0, zmm1		# zmm2 = 16 elements of a/b
	vmovups [rdi], zmm2

	vzeroupper

	ret
