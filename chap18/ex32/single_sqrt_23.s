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

	.globl _single_sqrt_23
	.globl single_sqrt_23

	# void single_sqrt_23(float *a, float *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_single_sqrt_23:
single_sqrt_23:

	vmovups zmm0, [rdi]

	vbroadcastss zmm3, half[rip]		# vbroadcastss zmm3, half
	vrsqrt14ps zmm1, zmm0
	vfpclassps k2, zmm0, 0xe
	vmulps zmm2, zmm0, zmm1, {rn-sae}
	vmulps zmm1, zmm1, zmm3
	knotw k3, k2
	vfnmadd231ps zmm0{k3}, zmm2, zmm2
	vfmadd213ps zmm0{k3}, zmm1, zmm2

	vmovups [rsi], zmm0

	vzeroupper

	ret

	.data
	.p2align 2

half:	.float 0.5

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
