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

	.globl _transpose_scalar
	.globl transpose_scalar

	# void transpose_scalar(uint16_t *out, const uint16_t *in)
	# On entry:
	#     rdi = out
	#     rsi = in

	.text

_transpose_scalar:
transpose_scalar:

	push rbx

					# mov rsi, pImage
					# mov rdi, pOutImage
	xor rdx, rdx
matrix_loop:
	xor rax, rax
outerloop:
	xor rbx, rbx
innerloop:
	mov rcx, rax
	shl rcx, 3
	add rcx, rbx
	mov r8w, word ptr [rsi+rcx*2]
	mov rcx, rbx
	shl rcx, 3
	add rcx, rax
	mov word ptr [rdi+rcx*2], r8w
	add rbx, 1
	cmp rbx, 8
	jne innerloop
	add rax, 1
	cmp rax, 8
	jne outerloop
	add rdx, 1
	add rsi, 64*2
	add rdi, 64*2
	cmp rdx, 50
	jne matrix_loop

	pop rbx
	ret
