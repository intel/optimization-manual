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

	.globl _avx_compress
	.globl avx_compress

	# uint64_t avx_compress(uint32_t *out, const uint32_t *in, uint64_t len)
	# On entry:
	#     rdi = out
	#     rsi = in
	#     rdx = len

	# On exit
	#     rax = out_len

	.text

_avx_compress:
avx_compress:

	push r13
	push r14
	push r15
	                                   # mov rsi, source
	                                   # mov rdi, dest
	mov r9, rdx                        # mov r9, len
	lea r14, shuffle_LUT[rip]          # mov r14, shuffle_LUT
	lea r15, write_mask[rip]           # mov r15, write_mask

	xor r8, r8
	xor r11, r11
	vpxor xmm0, xmm0, xmm0

mainloop:
	vmovdqa xmm1, [rsi+r8*4]
	vpcmpgtd xmm2, xmm1, xmm0
	mov r10, 4
	vmovmskps r13, xmm2
	shl r13, 4
	vmovdqu xmm3, [r14+r13]
	vpshufb xmm2, xmm1, xmm3

	popcnt r13, r13
	sub r10, r13
	vmovdqu xmm3, [r15+r10*4]
	vmaskmovps [rdi+r11*4], xmm3, xmm2
	add r11, r13
	add r8, 4
	cmp r8, r9
	jne mainloop

	vzeroupper

	pop r15
	pop r14
	pop r13

	mov rax, r11

	ret

	.data
	.p2align 4

shuffle_LUT:
	.int 0x80808080, 0x80808080, 0x80808080, 0x80808080
	.int 0x03020100, 0x80808080, 0x80808080, 0x80808080
	.int 0x07060504, 0x80808080, 0x80808080, 0x80808080
	.int 0x03020100, 0x07060504, 0x80808080, 0x80808080
	.int 0x0b0A0908, 0x80808080, 0x80808080, 0x80808080
	.int 0x03020100, 0x0b0A0908, 0x80808080, 0x80808080
	.int 0x07060504, 0x0b0A0908, 0x80808080, 0x80808080
	.int 0x03020100, 0x07060504, 0x0b0A0908, 0x80808080
	.int 0x0F0E0D0C, 0x80808080, 0x80808080, 0x80808080
	.int 0x03020100, 0x0F0E0D0C, 0x80808080, 0x80808080
	.int 0x07060504, 0x0F0E0D0C, 0x80808080, 0x80808080
	.int 0x03020100, 0x07060504, 0x0F0E0D0C, 0x80808080
	.int 0x0b0A0908, 0x0F0E0D0C, 0x80808080, 0x80808080
	.int 0x03020100, 0x0b0A0908, 0x0F0E0D0C, 0x80808080
	.int 0x07060504, 0x0b0A0908, 0x0F0E0D0C, 0x80808080
	.int 0x03020100, 0x07060504, 0x0b0A0908, 0x0F0E0D0C

write_mask:
	.int 0x80000000, 0x80000000, 0x80000000, 0x80000000
	.int 0x00000000, 0x00000000, 0x00000000, 0x00000000

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
