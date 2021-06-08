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

	.globl _ternary_vpternlog
	.globl ternary_vpternlog

	# void ternary_vpternlog(uint32_t *dest, const uint32_t *src1, const uint32_t *src2, const uint32_t *src3, uint64_t len)
	# On entry:
	#     rdi = dest
	#     rsi = src1
	#     rdx = src2
	#     rcx = src3
	#     r8 = len  ( must be divisible by 32 )

	.text

_ternary_vpternlog:
ternary_vpternlog:
	mov rax, r8

	mov r9, rsi			# mov r9, src1
	mov r8, rdx			# mov r8, src2
	mov r10, rcx			# mov r10, src3
	mov r11, rdi			# mov r11, dst
	mov rsi, rax			# mov rsi, len

	xor rax, rax
	
mainloop:
	vmovaps zmm1, [r8+rax*4]
	vmovaps zmm0, [r9+rax*4]
	vpternlogd zmm0,zmm1,[r10], 0x92
	vmovaps [r11], zmm0
	vmovaps zmm1, [r8+rax*4+0x40]
	vmovaps zmm0, [r9+rax*4+0x40]
	vpternlogd zmm0,zmm1, [r10+0x40], 0x92
	vmovaps [r11+0x40], zmm0
	add rax, 32
	add r10, 0x80
	add r11, 0x80
	cmp rax, rsi
	jne mainloop
	
	vzeroupper
	ret


