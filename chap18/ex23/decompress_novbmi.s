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

	.globl _decompress_novbmi
	.globl decompress_novbmi

	# void decompress_novbmi(int len, uint8_t *out, const uint8_t *in);
	# On entry:
	#     edi = len
	#     rsi = out
	#     rdx = in

	.text

_decompress_novbmi:
decompress_novbmi:
	                                     # mov rdx, compressedData
	mov r9, rsi                          # mov r9, decompressedData
	mov eax, edi                         # mov eax, numOfElements
	shr eax, 3
	xor rsi, rsi
loop:
	mov rcx, qword ptr [rdx]
	mov r10, rcx
	and r10, 0x1f
	mov r11, rcx
	mov byte ptr [r9+rsi*8], r10b
	mov r10, rcx
	shr r10, 0xa
	add rdx, 0x5
	and r10, 0x1f
	mov byte ptr [r9+rsi*8+0x2], r10b
	mov r10, rcx
	shr r10, 0xf
	and r10, 0x1f
	mov byte ptr [r9+rsi*8+0x3], r10b
	mov r10, rcx
	shr r10, 0x14
	and r10, 0x1f
	mov byte ptr [r9+rsi*8+0x4], r10b
	mov r10, rcx
	shr r10, 0x19
	and r10, 0x1f
	mov byte ptr [r9+rsi*8+0x5], r10b
	mov r10, rcx
	shr r11, 0x5
	shr r10, 0x1e
	and r11, 0x1f
	shr rcx, 0x23
	and r10, 0x1f
	and rcx, 0x1f
	mov byte ptr [r9+rsi*8+0x1], r11b
	mov byte ptr [r9+rsi*8+0x6], r10b
	mov byte ptr [r9+rsi*8+0x7], cl
	inc rsi
	cmp rsi, rax
	jb loop
	
	ret
