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

	.globl _double_rsqrt_50
	.globl double_rsqrt_50

	# void double_rsqrt_50(double *a, double *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_double_rsqrt_50:
double_rsqrt_50:

	vmovupd zmm3, [rdi]
	vmovapd zmm5, one[rip]		# vmovapd zmm5, One
	vmovapd zmm6, dc1[rip]		# vmovapd zmm6, dc1
	vmovapd zmm8, dc3[rip]		# vmovapd zmm8, dc3
	vmovapd zmm7, dc2[rip]		# vmovapd zmm7, dc2

	vrsqrt14pd zmm2, zmm3
	vfpclasspd k1, zmm3, 0x5e	# vfpclasspd k1, zmm3, 5eh
	vmulpd zmm0, zmm2, zmm3, {rn-sae}
	vfnmadd231pd zmm0, zmm2, zmm5
	vmulpd zmm1, zmm2, zmm0
	vmovapd zmm4, zmm8
	vfmadd213pd zmm4, zmm0, zmm7
	vfmadd213pd zmm4, zmm0, zmm6
	vfmadd213pd zmm4, zmm1, zmm2
	vorpd zmm4{k1}, zmm2, zmm2

	vmovupd [rsi], zmm4

	vzeroupper

	ret

	.data
	.p2align 6

one:
	.quad 0x3FF0000000000000
	.quad 0x3FF0000000000000
	.quad 0x3FF0000000000000
	.quad 0x3FF0000000000000
	.quad 0x3FF0000000000000
	.quad 0x3FF0000000000000
	.quad 0x3FF0000000000000
	.quad 0x3FF0000000000000
dc1:
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
	.quad 0x3FE0000000000000
dc2:
	.quad 0x3FD8000004600001
	.quad 0x3FD8000004600001
	.quad 0x3FD8000004600001
	.quad 0x3FD8000004600001
	.quad 0x3FD8000004600001
	.quad 0x3FD8000004600001
	.quad 0x3FD8000004600001
	.quad 0x3FD8000004600001
dc3:
	.quad 0x3FD4000005E80001
	.quad 0x3FD4000005E80001
	.quad 0x3FD4000005E80001
	.quad 0x3FD4000005E80001
	.quad 0x3FD4000005E80001
	.quad 0x3FD4000005E80001
	.quad 0x3FD4000005E80001
	.quad 0x3FD4000005E80001

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
