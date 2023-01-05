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

	.globl _single_rcps_22
	.globl single_rcps_22

	# void single_rcps_22(float *a, float *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_single_rcps_22:
single_rcps_22:

	vmovups zmm0, [rdi]

	vbroadcastss zmm1, one[rip]	# zmm1 = vector of 16 1s
	vsqrtps zmm2, zmm0
	vdivps zmm2, zmm1, zmm2

	vmovups [rsi], zmm2

	vzeroupper

	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 2

one:	.float 1.0

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
