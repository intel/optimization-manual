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

	.globl _scatter_scalar
	.globl scatter_scalar

	# void scatter_scalar(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = index
	#     rcx = len

	.text
_scatter_scalar:
scatter_scalar:

	push rbx

	# registers are already initialised correctly.
	# mov rdi, InBuf
	# mov rsi, OutBuf
	# mov rdx, Index
	mov r8, rcx

	xor rcx, rcx
loop1:
	movsxd rax, [rdx]
	mov ebx, [rdi]
	mov [rsi + 4*rax], ebx
	movsxd rax, [rdx + 4]
	mov ebx, [rdi + 4]
	mov [rsi + 4*rax], ebx
	movsxd rax, [rdx + 8]
	mov ebx, [rdi + 8]
	mov [rsi + 4*rax], ebx
	movsxd rax, [rdx + 12]
	mov ebx, [rdi + 12]
	mov [rsi + 4*rax], ebx
	movsxd rax, [rdx + 16]
	mov ebx, [rdi + 16]
	mov [rsi + 4*rax], ebx
	movsxd rax, [rdx + 20]
	mov ebx, [rdi + 20]
	mov [rsi + 4*rax], ebx
	movsxd rax, [rdx + 24]
	mov ebx, [rdi + 24]
	mov [rsi + 4*rax], ebx
	movsxd rax, [rdx + 28]
	mov ebx, [rdi + 28]
	mov [rsi + 4*rax], ebx
	add rdi, 32
	add rdx, 32
	add rcx, 8
	cmp rcx, r8
	jl loop1

	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
