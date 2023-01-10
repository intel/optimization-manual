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

	.globl _double_rsqrt_52
	.globl double_rsqrt_52

	# void double_rsqrt_52(double *a, double *out);
	# On entry:
	#     rdi = a
	#     rsi = out

	.text

_double_rsqrt_52:
double_rsqrt_52:

	vmovupd zmm4, [rdi]		# vbroadcastsd zmm4, big_num
	vmovapd zmm0, one[rip]		# vmovapd zmm0, One
	vmovapd zmm5, dc1[rip]		# vmovapd zmm5, dc1
	vmovapd zmm6, dc2[rip]		# vmovapd zmm6, dc2
	vmovapd zmm7, dc3[rip]		# vmovapd zmm7, dc3

	vrsqrt14pd zmm3, zmm4
	vfpclasspd k1, zmm4, 0x5e	# vfpclasspd k1, zmm4, 5eh
	vmulpd zmm1, zmm3, zmm4, {rn-sae}
	vfnmadd231pd zmm0, zmm3, zmm1
	vfmsub231pd zmm1, zmm3, zmm4, {rn-sae}
	vfnmadd213pd zmm1, zmm3, zmm0
	vmovups zmm0, zmm7
	vmulpd zmm2, zmm3, zmm1
	vfmadd213pd zmm0, zmm1, zmm6
	vfmadd213pd zmm0, zmm1, zmm5
	vfmadd213pd zmm0, zmm2, zmm3
	vorpd zmm0{k1}, zmm3, zmm3

	vmovups [rsi], zmm0

	vzeroupper

	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
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
