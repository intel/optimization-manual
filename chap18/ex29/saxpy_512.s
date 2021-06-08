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

	.globl _saxpy_512
	.globl saxpy_512

	# void saxpy_512(float* src, float *src2, size_t len, float *dst, float alpha);
	# On entry:
	#     rdi = src
	#     rsi = src2
	#     rdx = len (length in bytes of all three arrays)
	#     rcx = dst
	#     xmm0 = alpha


	.text

_saxpy_512:
saxpy_512:
	push rbx

	mov rax, rdi 			# mov rax, src1
	mov rbx, rsi			# mov rbx, src2
					# mov rcx, dst
					# mov rdx, len
	xor rdi, rdi
	vbroadcastss zmm0, xmm0		# vbroadcastss zmm0, alpha
mainloop:
	vmovups zmm1, [rax]
	vfmadd213ps zmm1, zmm0, [rbx]
	vmovups [rcx], zmm1
	vmovups zmm1, [rax+0x40]
	vfmadd213ps zmm1, zmm0, [rbx+0x40]
	vmovups [rcx+0x40], zmm1
	vmovups zmm1, [rax+0x80]
	vfmadd213ps zmm1, zmm0, [rbx+0x80]
	vmovups [rcx+0x80], zmm1
	vmovups zmm1, [rax+0xC0]
	vfmadd213ps zmm1, zmm0, [rbx+0xC0]
	vmovups [rcx+0xC0], zmm1
	add rax, 256
	add rbx, 256
	add rcx, 256
	add rdi, 64
	cmp rdi, rdx
	jl mainloop

	pop rbx

	vzeroupper

	ret
