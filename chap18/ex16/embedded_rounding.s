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

	.globl _embedded_rounding
	.globl embedded_rounding

	# void void embedded_rounding(const float *a, const float *b, float* out);
	#
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = out

	.text

_embedded_rounding:
embedded_rounding:

	vmovups zmm2, [rdi]
	vmovups zmm4, [rsi]

	mov ecx, 0xffff
	kmovw k6, ecx

	vaddps zmm7 {k6}, zmm2, zmm4, {ru-sae}

	vmovups [rdx], zmm7
	vzeroupper
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
