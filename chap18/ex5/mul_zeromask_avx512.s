#
# Copyright (C) 2022 by Intel Corporation
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

	.globl _mul_zeromask_avx512
	.globl mul_zeromask_avx512

	# void mul_zeromask_avx512(float *a, float *b, float *out1, float *out2, size_t N);
	# On entry:
	#	 rdi = a
	#	 rsi = b
	#	 rdx = out1
	#	 rcx = out2
	#	 r8  = N

	.text

_mul_zeromask_avx512:
mul_zeromask_avx512:

	push rbx

	vmovups zmm9, zmmword ptr [rdi]   # vmovups zmm9, a
	vmovups zmm8, zmmword ptr [rsi]   # vmovups zmm8, b
	vmovups zmm0, zmmword ptr [rdx]   # vmovups zmm0, out1
	vmovups zmm1, zmmword ptr [rcx]   # vmovups zmm1, out2
	mov rbx, r8                       # mov rbx, N

	mov r8, 0x5555
	kmovw k1, r8d

loop:
	vmulps zmm0{k1}{z}, zmm9, zmm8
	vmulps zmm1{k1}{z}, zmm9, zmm8
	dec rbx
	jnle loop

	vmovups zmmword ptr [rdx], zmm0
	vmovups zmmword ptr [rcx], zmm1
	vzeroupper
	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
