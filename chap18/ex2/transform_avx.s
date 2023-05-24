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

	.globl _transform_avx
	.globl transform_avx

	# void transform_avx(float *cos_sin_theta_vec, float *sin_cos_theta_vec,
	#	float *in, float *out, size_t len);
	# On entry:
	#     rdi = cos_sin_theta_vec
	#     rsi = sin_cos_theta_vec
	#     rdx = in
	#     rcx = out
	#     r8 = len

	.text

_transform_avx:
transform_avx:
	mov r9, r8

	mov rax, rdx # mov rax,pInVector
	mov r8, rcx  # mov r8,pOutVector
	# Load into a ymm register of 32 bytes
	vmovups ymm3, ymmword ptr[rdi] # vmovups ymm3, ymmword ptr[cos_sin_theta_vec]
	vmovups ymm4, ymmword ptr[rsi] # vmovups ymm4, ymmword ptr[sin_cos_theta_vec]

	mov edx, r9d # mov edx, len
	shl edx, 2
	xor ecx, ecx
loop1:
	vmovsldup ymm0, [rax+rcx]
	vmovshdup ymm1, [rax+rcx]
	vmulps ymm1, ymm1, ymm4
	vfmaddsub213ps ymm0, ymm3, ymm1
	# 32 byte store from a ymm register
	vmovaps [r8+rcx], ymm0
	vmovsldup ymm0, [rax+rcx+32]
	vmovshdup ymm1, [rax+rcx+32]
	vmulps ymm1, ymm1, ymm4
	vfmaddsub213ps ymm0, ymm3, ymm1
	# offset 32 bytes from previous store
	vmovaps [r8+rcx+32], ymm0
	# Processed 64bytes in this loop
	# (the code is unrolled twice)
	add ecx, 64
	cmp ecx, edx
	jl loop1

	vzeroupper	
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
