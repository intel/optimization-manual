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

	.globl _single_rcps_23
	.globl single_rcps_23

	# void single_rcps_23(float *a, float *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_single_rcps_23:
single_rcps_23:

	vmovups zmm0, [rdi]

	vbroadcastss zmm1, half[rip]		# zmm1 = vector of 16 0.5s
	vrsqrt14ps zmm2, zmm0
	vmulps zmm3, zmm0, zmm2
	vmulps zmm4, zmm1, zmm2
	vfnmadd231ps zmm1, zmm3, zmm4
	vfmsub231ps zmm3, zmm0, zmm2
	vfnmadd231ps zmm1, zmm4, zmm3
	vfmadd231ps zmm2, zmm2, zmm1

	vmovups [rsi], zmm2

	vzeroupper

	ret

	.data
	.p2align 2

half:	.float 0.5
