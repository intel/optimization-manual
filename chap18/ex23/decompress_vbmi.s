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

	.globl _decompress_vbmi
	.globl decompress_vbmi

	# void decompress_vbmi(uint8_t *out, const uint8_t *in, int len);
	# On entry:
	#     rdi = out
	#     rsi = in
	#     edx = len

	.text

_decompress_vbmi:
decompress_vbmi:
	//asm:
	                                   # mov rsi, compressedData
	                                   # mov rdi, decompressedData
	mov r8d, edx                       # mov r8d,numOfElements
	lea r8, [rdi+r8]
	mov r9, 0x1F1F1F1F
	vpbroadcastd zmm12, r9d
	vmovdqu32 zmm10, permute_ctrl[rip]
	vmovdqu32 zmm11, multishift_ctrl[rip]
loop:
	vmovdqu32 zmm1, [rsi]
	vpermb zmm2, zmm10, zmm1
	vpmultishiftqb zmm2, zmm11, zmm2
	vpandq zmm2, zmm12, zmm2
	vmovdqu32 [rdi], zmm2
	add rdi, 64
	add rsi, 40
	cmp rdi, r8
	jl loop

	vzeroupper
	ret

	.data
	.p2align 6

permute_ctrl:
	.byte 0, 1, 2, 3, 4, 0,0,0
	.byte 5, 6, 7, 8, 9, 0,0,0
	.byte 10,11,12,13,14,0,0,0
	.byte 15,16,17,18,19,0,0,0
	.byte 20,21,22,23,24,0,0,0
	.byte 25,26,27,28,29,0,0,0
	.byte 30,31,32,33,34,0,0,0
	.byte 35,36,37,38,39,0,0,0

multishift_ctrl:
	.byte 0, 5, 10,15,20,25,30,35
	.byte 0, 5, 10,15,20,25,30,35
	.byte 0, 5, 10,15,20,25,30,35
	.byte 0, 5, 10,15,20,25,30,35
	.byte 0, 5, 10,15,20,25,30,35
	.byte 0, 5, 10,15,20,25,30,35
	.byte 0, 5, 10,15,20,25,30,35
	.byte 0, 5, 10,15,20,25,30,35

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif

