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

	.globl _g2s_vpermi2d
	.globl g2s_vpermi2d

	# void g2s_vpermi2d(uint32_t len, complex_num *complex_buffer,
	#	            float *imaginary_buffer, float *real_buffer);
	#     edi = len
	#     rsi = complex_buffer
	#     rdx = imaginary_buffer
	#     rcx = real_buffer


	.text

_g2s_vpermi2d:
g2s_vpermi2d:

	vmovaps zmm6, gather_imag_index[rip]
	vmovaps zmm7, gather_real_index[rip]

	mov r10d, edi
	mov r8, rdx
	mov rdx, rsi
	xor r9, r9

loop:
	vmovups zmm4, [rdx+r9*8]
	vmovups zmm0, [rdx+r9*8+0x40]
	vmovups zmm5, [rdx+r9*8+0x80]
	vmovups zmm1, [rdx+r9*8+0xc0]
	vmovaps zmm2, zmm7
	vmovaps zmm3, zmm7
	vpermi2d zmm2, zmm4, zmm0
	vpermt2d zmm4, zmm6, zmm0
	vpermi2d zmm3, zmm5, zmm1
	vpermt2d zmm5, zmm6, zmm1
	vmovdqu32 [rcx+r9*4], zmm2
	vmovdqu32 [rcx+r9*4+0x40], zmm3
	vmovdqu32 [r8+r9*4], zmm4
	vmovdqu32 [r8+r9*4+0x40], zmm5
	add r9, 0x20
	cmp r9, r10
	jb loop

	vzeroupper

	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 6

gather_imag_index:
	.4byte 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31
gather_real_index:
	.4byte 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
