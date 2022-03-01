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

	.globl _ternary_avx512
	.globl ternary_avx512

	# void ternary_avx512(uint32_t *dest, const uint32_t *src1, const uint32_t *src2, const uint32_t *src3, uint64_t len)
	# On entry:
	#     rdi = dest
	#     rsi = src1
	#     rdx = src2
	#     rcx = src3
	#     r8 = len  ( must be divisible by 32 )

	.text

_ternary_avx512:
ternary_avx512:
	mov r9, rdi
	
	mov rdi, rsi			# mov rdi, src1
	mov rsi, rdx			# mov rsi, src2
	mov rdx, rcx			# mov rdx, src3
	mov r11, r9			# mov r11, dst
	
	mov r9, r8			# mov r8, len
	xor r10, r10

mainloop:
	vmovups zmm2, zmmword ptr [rdi+r10*4]
	vmovups zmm4, zmmword ptr [rdi+r10*4+0x40]
	vmovups zmm6, zmmword ptr [rsi+r10*4]
	vmovups zmm8, zmmword ptr [rsi+r10*4+0x40]
	vmovups zmm3, zmmword ptr [rdx+r10*4]
	vmovups zmm5, zmmword ptr [rdx+r10*4+0x40]
	vpandd zmm0, zmm2, zmm6
	vpandd zmm1, zmm4, zmm8
	vpxord zmm7, zmm2, zmm3
	vpxord zmm9, zmm4, zmm5
	vpandd zmm10, zmm0, zmm3
	vpandd zmm12, zmm1, zmm5
	vpandnd zmm11, zmm6, zmm7
	vpandnd zmm13, zmm8, zmm9
	vpord zmm14, zmm10, zmm11
	vpord zmm15, zmm12, zmm13
	vmovups zmmword ptr [r11+r10*4], zmm14
	vmovups zmmword ptr [r11+r10*4+0x40], zmm15
	add r10, 0x20
	cmp r10, r9
	jb mainloop
	
	vzeroupper
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
