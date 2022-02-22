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

	.globl _double_rsqrt_51
	.globl double_rsqrt_51

	# void double_rsqrt_51(double *a, double *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_double_rsqrt_51:
double_rsqrt_51:

	vmovupd zmm0, [rdi]
	vbroadcastsd zmm1, one[rip]

	vsqrtpd zmm0, zmm0
	vdivpd zmm0, zmm1, zmm0

	vmovupd [rsi], zmm0

	vzeroupper

	ret

	.data
	.p2align 3

one:	.double 1.0

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
