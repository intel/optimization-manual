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

	.globl _avx512_vector_dp
	.globl avx512_vector_dp

	# double avx512_vector_dp(const uint32_t *a_index, const double *a_value,
	#			  const uint32_t *b_index, const double *b_value,
	#			  uint64_t max_els);
	#
	# On entry:
	#     rdi = a_index
	#     rsi = a_value
	#     rdx = b_index
	#     rcx = b_value
	#     r8 = max_els

	.text

_avx512_vector_dp:
avx512_vector_dp:

	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r11, r8
	sub r11, 8

	xchg rdx, rdi			# mov rdx, A_index
	xor rbx, rbx
	xchg rcx, rbx			# mov rcx, A_offset
	mov rax, rsi			# mov rax, A_value
	mov r12, rdi			# mov r12, B_index
	xor r13, r13			# mov r13, B_offset
					# mov rbx, B_value

	vpxord zmm4, zmm4, zmm4
	lea r14, all_31s[rip]		# mov r14, all_31s	// array of {31, 31, ...}
	vmovaps zmm2, [r14]
	lea r15, upconvert_control[rip] # mov r15, upconvert_control // array of {0, 7, 0, 6, 0, 5, 0, 4, 0, 3, 0, 2, 0, 1, 0, 0}
	vmovaps zmm1, [r15]
	vpternlogd zmm0, zmm0, zmm0, 255
	mov esi, 21845
	kmovw k1, esi 			# odd bits set

loop:
	cmp rcx, r11
	ja vector_end

	cmp r13, r11
	ja vector_end

	# read 8 indices for A
	vmovdqu ymm5, [rdx+rcx*4]
	# read 8 indices for B, and put
	# them in the high part of zmm6
	vinserti64x4 zmm6, zmm5, [r12+r13*4], 1
	vpconflictd zmm7, zmm6
	# extract A vs. B comparisons
	vextracti64x4 ymm8, zmm7, 1
	# convert comparison results to
	# permute control
	vplzcntd zmm9, zmm8
	vptestmd k2, zmm8, zmm0
	vpsubd zmm10, zmm2, zmm9
	# upconvert permute controls from
	# 32b to 64b, since data is 64b
	vpermd zmm11{k1}, zmm1, zmm10
	# Move A values to corresponding
	# B values, and do FMA
	vpermpd zmm12{k2}{z}, zmm11, [rax+rcx*8]
	vfmadd231pd zmm4, zmm12, [rbx+r13*8]

	# Update the offsets

	mov r9d, dword ptr [rdx+rcx*4+28]
	mov r10d, dword ptr [r12+r13*4+28]
	cmp r9d, r10d
	ja a_has_biggest_index
	jb b_has_biggest_index
	add rcx, 8
	add r13, 8
	jmp loop

a_has_biggest_index:
	vpcmpd k3, ymm5, [r12+r13*4+28]{1to8}, 1
	add r13, 8
	kmovd r9d, k3
	lzcnt r9d, r9d
	add rcx, 32
	sub rcx, r9
	jmp loop


b_has_biggest_index:
	vextracti64x4 ymm5, zmm6, 1
	vpcmpd k3, ymm5, [rdx+rcx*4+28]{1to8}, 1
	add rcx, 8
	kmovd r9d, k3
	lzcnt r9d, r9d
	add r13, 32
	sub r13, r9
	jmp loop

vector_end:
	vextracti64x4 ymm3, zmm4, 1
	vaddpd ymm4, ymm3, ymm4
	vextracti32x4 xmm3, ymm4, 1
	vzeroupper
	vaddpd xmm0, xmm3, xmm4
	haddpd xmm0, xmm0

scalar_loop:
	cmp rcx, r8
	jae end

	cmp r13, r8
	jae end

	mov r10d, dword ptr [rdx+rcx*4]
	mov r11d, dword ptr [r12+r13*4]
	cmp r10d, r11d
	jne skip_fma

	// do the fma on a match
	movsd xmm5, [rbx+r13*8]
	mulsd xmm5, [rax+rcx*8]
	addsd xmm0, xmm5
	inc rcx
	inc r13
	jmp scalar_loop

skip_fma:
	jae increment_b
	inc rcx
	jmp scalar_loop
increment_b:
	inc r13
	jmp scalar_loop

end:

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx

	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 6
all_31s:
	.quad 0x0000001f0000001f
	.quad 0x0000001f0000001f
	.quad 0x0000001f0000001f
	.quad 0x0000001f0000001f
	.quad 0x0000001f0000001f
	.quad 0x0000001f0000001f
	.quad 0x0000001f0000001f
	.quad 0x0000001f0000001f
upconvert_control:
	.quad 0x0000000000000000
	.quad 0x0000000000000001
	.quad 0x0000000000000002
	.quad 0x0000000000000003
	.quad 0x0000000000000004
	.quad 0x0000000000000005
	.quad 0x0000000000000006
	.quad 0x0000000000000007

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
