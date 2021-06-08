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

	.globl _scalar
	.globl scalar

	# void scalar(size_t len, complex_num* complex_buffer, float* imaginary_buffer,
	#             float* real_buffer);
	# On entry:
	#     rdi = len (length in elements of )
	#     rsi = complex_buffer
	#     rdx = imaginary_buffer
	#     rcx = real_buffer

	.text

_scalar:
scalar:
	mov r8, rdi
	shr r8, 1
	xor r10, r10

loop:
	lea eax, [r10+r10*1]
	movsxd rax, eax
	inc r10d
	mov r11d, dword ptr [rsi+rax*8]
	mov dword ptr [rcx+rax*4], r11d
	mov r11d, dword ptr [rsi+rax*8+0x4]
	mov dword ptr [rdx+rax*4], r11d
	mov r11d, dword ptr [rsi+rax*8+0x8]
	mov dword ptr [rcx+rax*4+0x4], r11d
	mov r11d, dword ptr [rsi+rax*8+0xc]
	mov dword ptr [rdx+rax*4+0x4], r11d
	cmp r10d, r8d
	jl loop

	ret
