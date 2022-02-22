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

	.globl _ternary_avx2
	.globl ternary_avx2

	# void ternary_avx2(uint32_t *dest, const uint32_t *src1, const uint32_t *src2, const uint32_t *src3, uint64_t len)
	# On entry:
	#     rdi = dest
	#     rsi = src1
	#     rdx = src2
	#     rcx = src3
	#     r8 = len  ( must be divisible by 16 )

	.text

_ternary_avx2:
ternary_avx2:
	push rbx
	
	mov rax, rsi			# mov rax, src1
	mov rbx, rdx			# mov rbx, src2
					# mov rcx, src3
	mov r11, rdi			# mov r11, dst
					# mov r8, len
	xor r10, r10
	
mainloop:
	vmovdqu ymm1, ymmword ptr [rax+r10*4]
	vmovdqu ymm3, ymmword ptr [rdx+r10*4]
	vmovdqu ymm2, ymmword ptr [rcx+r10*4]
	vmovdqu ymm10, ymmword ptr [rcx+r10*4+0x20]
	vpand ymm0, ymm1, ymm3
	vpxor ymm4, ymm1, ymm2
	vpand ymm5, ymm0, ymm2
	vpandn ymm6, ymm3, ymm4
	vpor ymm7, ymm5, ymm6
	vmovdqu ymmword ptr [r11+r10*4], ymm7
	vmovdqu ymm9, ymmword ptr [rax+r10*4+0x20]
	vmovdqu ymm11, ymmword ptr [rdx+r10*4+0x20]
	vpxor ymm12, ymm9, ymm10
	vpand ymm8, ymm9, ymm11
	vpandn ymm14, ymm11, ymm12
	vpand ymm13, ymm8, ymm10
	vpor ymm15, ymm13, ymm14
	vmovdqu ymmword ptr [r11+r10*4+0x20], ymm15
	add r10, 0x10
	cmp r10, r8
	jb mainloop

	pop rbx
	
	vzeroupper
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
