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

	.globl _transform_avx512
	.globl transform_avx512

	# void transform_avx512(float *cos_sin_teta_vec, float *sin_cos_teta_vec,
	#	float *in, float *out, size_t len);
	# On entry:
	#     rdi = cos_sin_teta_vec
	#     rsi = sin_cos_teta_vec
	#     rdx = in
	#     rcx = out
	#     r8 = len

	.text

_transform_avx512:
transform_avx512:
	mov r9, r8

	mov rax, rdx # mov rax,pInVector
	mov r8, rcx  # mov r8,pOutVector
	# Load into a zmm register of 64 bytes
	vmovups zmm3, zmmword ptr[rdi] # vmovups zmm3, zmmword ptr[cos_sin_teta_vec]
	vmovups zmm4, zmmword ptr[rsi] # vmovups zmm4, zmmword ptr[sin_cos_teta_vec]
	mov edx, r9d # mov edx, len
	shl edx, 2
	xor ecx, ecx
loop1:
	vmovsldup zmm0, [rax+rcx]
	vmovshdup zmm1, [rax+rcx]
	vmulps zmm1, zmm1, zmm4
	vfmaddsub213ps zmm0, zmm3, zmm1
	# 64 byte store from a zmm register
	vmovaps [r8+rcx], zmm0
	vmovsldup zmm0, [rax+rcx+64]
	vmovshdup zmm1, [rax+rcx+64]
	vmulps zmm1, zmm1, zmm4
	vfmaddsub213ps zmm0, zmm3, zmm1
	# offset 64 bytes from previous store
	vmovaps [r8+rcx+64], zmm0
	# Processed 128bytes in this loop
	# (the code is unrolled twice)
	add ecx, 128
	cmp ecx, edx
	jl loop1

	vzeroupper	
	ret
