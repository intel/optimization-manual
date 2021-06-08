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

	.globl _scalar_histogram
	.globl scalar_histogram

	# void scalar_histogram(const int32_t *input, uint32_t *output, uint64_t num_inputs, uint64_t bins);
	#
	# On entry:
	#     rdi = input
	#     rsi = ouptut
	#     rdx = num_inputs
	#     rcx = bins

	.text

_scalar_histogram:
scalar_histogram:

	push rbx
	push r15

	mov r9d, ecx			# mov r9d, bins_minus_1
	dec r9d
	mov ebx, edx			# mov ebx, num_inputs
	shr ebx, 1
	mov r10, rdi			# mov r10, pInput	
	mov r15, rsi			# mov r15, pHistogram
	xor rax, rax

histogram_loop:
	lea ecx, [rax + rax]
	inc eax
	movsxd rcx, ecx
	mov esi, [r10+rcx*4]
	and esi, r9d
	mov r8d, [r10+rcx*4+4]
	movsxd rsi, esi
	and r8d, r9d
	movsxd r8, r8d
	inc dword ptr [r15+rsi*4]
	inc dword ptr [r15+r8*4]
	cmp eax, ebx
	jb histogram_loop

	pop r15
	pop rbx

	ret
