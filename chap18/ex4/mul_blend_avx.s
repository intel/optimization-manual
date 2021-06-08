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

	.globl _mul_blend_avx
	.globl mul_blend_avx

	# void mul_blend_avx(double *a, double *b, double *c, size_t N);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = c
	#     rcx = N

	.text

_mul_blend_avx:
mul_blend_avx:

	mov rax, rdi        # mov rax, a
	mov r11, rsi        # mov r11, b
	mov r8, rcx         # mov r8, N
	shr r8, 5
	mov rsi, rdx        # mov rsi, c

	xor rcx, rcx
	xor r9, r9
	
loop:
	vmovupd ymm1, ymmword ptr [rax+rcx*8]
	inc r9d
	vmovupd ymm6, ymmword ptr [rax+rcx*8+0x20]
	vmovupd ymm2, ymmword ptr [r11+rcx*8]
	vmovupd ymm7, ymmword ptr [r11+rcx*8+0x20]
	vmovupd ymm11, ymmword ptr [rax+rcx*8+0x40]
	vmovupd ymm12, ymmword ptr [r11+rcx*8+0x40]
	vcmppd ymm4, ymm0, ymm1, 0x1
	vcmppd ymm9, ymm0, ymm6, 0x1
	vcmppd ymm14, ymm0, ymm11, 0x1
	vandpd ymm16, ymm1, ymm4
	vandpd ymm17, ymm6, ymm9
	vmulpd ymm3, ymm16, ymm2
	vmulpd ymm8, ymm17, ymm7
	vmovupd ymm1, ymmword ptr [rax+rcx*8+0x60]
	vmovupd ymm6, ymmword ptr [rax+rcx*8+0x80]
	vblendvpd ymm5, ymm2, ymm3, ymm4
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vmovupd ymm2, ymmword ptr [r11+rcx*8+0x60]
	vmovupd ymm7, ymmword ptr [r11+rcx*8+0x80]
	vmovupd ymmword ptr [rsi], ymm5
	vmovupd ymmword ptr [rsi+0x20], ymm10
	vcmppd ymm4, ymm0, ymm1, 0x1
	vcmppd ymm9, ymm0, ymm6, 0x1
	vandpd ymm18, ymm11, ymm14
	vandpd ymm19, ymm1, ymm4
	vandpd ymm20, ymm6, ymm9
	vmulpd ymm13, ymm18, ymm12
	vmulpd ymm3, ymm19, ymm2
	vmulpd ymm8, ymm20, ymm7
	vmovupd ymm11, ymmword ptr [rax+rcx*8+0xa0]
	vmovupd ymm1, ymmword ptr [rax+rcx*8+0xc0]
	vmovupd ymm6, ymmword ptr [rax+rcx*8+0xe0]
	vblendvpd ymm15, ymm12, ymm13, ymm14
	vblendvpd ymm5, ymm2, ymm3, ymm4
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vmovupd ymm12, ymmword ptr [r11+rcx*8+0xa0]
	vmovupd ymm2, ymmword ptr [r11+rcx*8+0xc0]
	vmovupd ymm7, ymmword ptr [r11+rcx*8+0xe0]
	vmovupd ymmword ptr [rsi+0x40], ymm15
	vmovupd ymmword ptr [rsi+0x60], ymm5
	vmovupd ymmword ptr [rsi+0x80], ymm10
	vcmppd ymm14, ymm0, ymm11, 0x1
	vcmppd ymm4, ymm0, ymm1, 0x1
	vcmppd ymm9, ymm0, ymm6, 0x1
	vandpd ymm21, ymm11, ymm14
	add rcx, 0x20
	vandpd ymm22, ymm1, ymm4
	vandpd ymm23, ymm6, ymm9
	vmulpd ymm13, ymm21, ymm12
	vmulpd ymm3, ymm22, ymm2
	vmulpd ymm8, ymm23, ymm7
	vblendvpd ymm15, ymm12, ymm13, ymm14
	vblendvpd ymm5, ymm2, ymm3, ymm4
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vmovupd ymmword ptr [rsi+0xa0], ymm15
	vmovupd ymmword ptr [rsi+0xc0], ymm5
	vmovupd ymmword ptr [rsi+0xe0], ymm10
	add rsi, 0x100
	cmp r9d, r8d
	jb loop

	vzeroupper	
	ret
