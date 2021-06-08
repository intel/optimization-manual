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

	.globl _single_sqrt_14
	.globl single_sqrt_14

	# void single_sqrt_14(float *a, float *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_single_sqrt_14:
single_sqrt_14:

	vmovups zmm0, [rdi]

	vrsqrt14ps zmm1, zmm0
	vfpclassps k2, zmm0, 0xe
	knotw k3, k2
	vmulps zmm0{k3}, zmm0, zmm1

	vmovups [rsi], zmm0

	vzeroupper

	ret
