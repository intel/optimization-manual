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

	.globl _gather_scalar
	.globl gather_scalar

	# void gather_scalar(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = index
	#     rcx = len

	.text
_gather_scalar:
gather_scalar:

	push rbx

	# registers are already initialised correctly.
	# mov rdi, InBuf
	# mov rsi, OutBuf
	# mov rdx, Index
	mov r8, rcx

	xor rcx, rcx
loop1:
	mov rax, [rdx]
	movsxd rbx, eax
	sar rax, 32
	mov ebx,[rdi + 4*rbx]
	mov [rsi], ebx
	mov eax,[rdi + 4*rax]
	mov [rsi + 4], eax
	mov rax, [rdx + 8]
	movsxd rbx, eax
	sar rax, 32
	mov ebx, [rdi + 4*rbx]
	mov [rsi + 8], ebx
	mov eax,[rdi + 4*rax]
	mov [rsi + 12], eax
	mov rax, [rdx + 16]
	movsxd rbx, eax
	sar rax, 32
	mov ebx, [rdi + 4*rbx]
	mov [rsi + 16], ebx
	mov eax, [rdi + 4*rax]
	mov [rsi + 20], eax
	mov rax, [rdx + 24]
	movsxd rbx, eax
	sar rax, 32
	mov ebx, [rdi + 4*rbx]
	mov [rsi + 24], ebx
	mov eax, [rdi + 4*rax]
	mov [rsi + 28], eax
	add rsi, 32
	add rdx, 32
	add rcx, 8
	cmp rcx, r8             # cmp rcx, len
	jl loop1

	pop rbx

	ret
