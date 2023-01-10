#
# Copyright (C) 2022 by Intel Corporation
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

# M and N here are for the matrix in VNNI format

#define M 16
#define N 16
#define ON 64
#define I_STRIDE (N*2)
#define O_STRIDE (ON*2)

	.intel_syntax noprefix

	.globl _vnni_to_vnni_bf16_trans
	.globl vnni_to_vnni_bf16_trans

	# void vnni_to_vnni_bf16_trans(const bfloat_16 *input, bfloat_16 *output);
	# On entry:
	#     rdi = input
	#     rsi = output

	.text

_vnni_to_vnni_bf16_trans:
vnni_to_vnni_bf16_trans:

	mov r8, rdi
	mov r9, rsi
	vbroadcasti32x4 zmm31, shuflle_cntrl[rip]

	mov r10, 0xf0
	kmovd k1, r10d
	mov r10, 0xf00
	kmovd k2, r10d
	mov r10, 0xf000
	kmovd k3, r10d
	mov rax, N / 8
L_N:
	mov rdx, M / 8
L_M:

	vbroadcasti32x4 zmm0, xmmword ptr [r8]
	vbroadcasti32x4 zmm0{k1}, xmmword ptr [r8+I_STRIDE*2]
	vbroadcasti32x4 zmm0{k2}, xmmword ptr [r8+I_STRIDE*4]
	vbroadcasti32x4 zmm0{k3}, xmmword ptr [r8+I_STRIDE*6]
	vbroadcasti32x4 zmm1, xmmword ptr [r8+I_STRIDE*1]
	vbroadcasti32x4 zmm1{k1}, xmmword ptr [r8+I_STRIDE*3]
	vbroadcasti32x4 zmm1{k2}, xmmword ptr [r8+I_STRIDE*5]
	vbroadcasti32x4 zmm1{k3}, xmmword ptr [r8+I_STRIDE*7]

	vpshufb zmm2, zmm0, zmm31
	vpshufb zmm3, zmm1, zmm31
	vpunpcklqdq zmm0, zmm2, zmm3
	vpunpckhqdq zmm1, zmm2, zmm3

	vmovdqu16 zmmword ptr [r9], zmm0
	vmovdqu16 zmmword ptr [r9+O_STRIDE], zmm1

	add r9, 0x40
	add r8, I_STRIDE*8
	dec rdx
	jnz L_M

	add r9, (O_STRIDE*2) - ((M/8) * 0x40)
	sub r8, (I_STRIDE*M-0x10)
	dec rax
	jnz L_N

	vzeroupper
	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
.p2align 4

shuflle_cntrl:
	.4byte 0x05040100, 0x07060302, 0x0d0c0908, 0x0f0e0b0a

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
