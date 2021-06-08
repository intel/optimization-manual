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

	.globl _qword_avx2_ass
	.globl qword_avx2_ass

	# void qword_avx2_ass(const int64_t *a, const int64_t *b, int64_t *c, uint64_t count);
	#
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = c
	#     rcx = count

	.text

_qword_avx2_ass:
qword_avx2_ass:

	mov rax, rdi
	mov r11, rsi
	mov rsi, rdx
	mov r8, rcx
	shr r8, 5
	xor rcx, rcx
	xor r9d, r9d

loop:
	vmovdqu32 ymm28, ymmword ptr [rax+rcx*8+0x20]
	inc r9d
	vmovdqu32 ymm26, ymmword ptr [r11+rcx*8+0x20]
	vmovdqu32 ymm17, ymmword ptr [r11+rcx*8]
	vmovdqu32 ymm19, ymmword ptr [rax+rcx*8]
	vmovdqu ymm13, ymmword ptr [rax+rcx*8+0x40]
	vmovdqu ymm11, ymmword ptr [r11+rcx*8+0x40]
	vpsrlq ymm25, ymm28, 0x20
	vpsrlq ymm27, ymm26, 0x20
	vpsrlq ymm16, ymm19, 0x20
	vpsrlq ymm18, ymm17, 0x20
	vpaddq ymm6, ymm28, ymm26
	vpsrlq ymm10, ymm13, 0x20
	vpsrlq ymm12, ymm11, 0x20
	vpaddq ymm0, ymm19, ymm17
	vpmuludq ymm29, ymm25, ymm26
	vpmuludq ymm30, ymm27, ymm28
	vpaddd ymm31, ymm29, ymm30
	vmovdqu32 ymm29, ymmword ptr [r11+rcx*8+0x80]
	vpsllq ymm5, ymm31, 0x20
	vmovdqu32 ymm31, ymmword ptr [rax+rcx*8+0x80]
	vpsrlq ymm30, ymm29, 0x20
	vpmuludq ymm20, ymm16, ymm17
	vpmuludq ymm21, ymm18, ymm19
	vpmuludq ymm4, ymm28, ymm26
	vpaddd ymm22, ymm20, ymm21
	vpaddq ymm7, ymm4, ymm5
	vpsrlq ymm28, ymm31, 0x20
	vmovdqu32 ymm20, ymmword ptr [r11+rcx*8+0x60]
	vpsllq ymm24, ymm22, 0x20
	vmovdqu32 ymm22, ymmword ptr [rax+rcx*8+0x60]
	vpsrlq ymm21, ymm20, 0x20
	vpaddq ymm4, ymm22, ymm20
	vpcmpgtq ymm8, ymm7, ymm6
	vblendvpd ymm9, ymm6, ymm7, ymm8
	vmovups ymmword ptr [rsi+0x20], ymm9
	vpmuludq ymm14, ymm10, ymm11
	vpmuludq ymm15, ymm12, ymm13
	vpmuludq ymm8, ymm28, ymm29
	vpmuludq ymm9, ymm30, ymm31
	vpmuludq ymm23, ymm19, ymm17
	vpaddd ymm16, ymm14, ymm15
	vpsrlq ymm19, ymm22, 0x20
	vpaddd ymm10, ymm8, ymm9
	vpaddq ymm1, ymm23, ymm24
	vpsllq ymm18, ymm16, 0x20
	vmovdqu32 ymm28, ymmword ptr [rax+rcx*8+0xc0]
	vpsllq ymm12, ymm10, 0x20
	vpmuludq ymm23, ymm19, ymm20
	vpmuludq ymm24, ymm21, ymm22
	vpaddd ymm25, ymm23, ymm24
	vmovdqu32 ymm19, ymmword ptr [rax+rcx*8+0xa0]
	vpsllq ymm27, ymm25, 0x20
	vpsrlq ymm25, ymm28, 0x20
	vpsrlq ymm16, ymm19, 0x20
	vpcmpgtq ymm2, ymm1, ymm0
	vblendvpd ymm3, ymm0, ymm1, ymm2
	vpaddq ymm0, ymm13, ymm11
	vmovups ymmword ptr [rsi], ymm3
	vpmuludq ymm17, ymm13, ymm11
	vpmuludq ymm11, ymm31, ymm29
	vpaddq ymm1, ymm17, ymm18
	vpaddq ymm13, ymm31, ymm29
	vpaddq ymm14, ymm11, ymm12
	vmovdqu32 ymm17, ymmword ptr [r11+rcx*8+0xa0]
	vmovdqu ymm12, ymmword ptr [r11+rcx*8+0xe0]
	vpsrlq ymm18, ymm17, 0x20
	vpcmpgtq ymm2, ymm1, ymm0
	vpmuludq ymm26, ymm22, ymm20
	vpcmpgtq ymm15, ymm14, ymm13
	vblendvpd ymm3, ymm0, ymm1, ymm2
	vblendvpd ymm0, ymm13, ymm14, ymm15
	vmovdqu ymm14, ymmword ptr [rax+rcx*8+0xe0]
	vmovups ymmword ptr [rsi+0x40], ymm3
	vmovups ymmword ptr [rsi+0x80], ymm0
	vpaddq ymm5, ymm26, ymm27
	vpsrlq ymm11, ymm14, 0x20
	vpsrlq ymm13, ymm12, 0x20
	vpaddq ymm1, ymm19, ymm17
	vpaddq ymm0, ymm14, ymm12
	vmovdqu32 ymm26, ymmword ptr [r11+rcx*8+0xc0]
	vpmuludq ymm20, ymm16, ymm17
	add rcx, 0x20
	vpmuludq ymm21, ymm18, ymm19
	vpaddd ymm22, ymm20, ymm21
	vpsrlq ymm27, ymm26, 0x20
	vpsllq ymm24, ymm22, 0x20
	vpmuludq ymm29, ymm25, ymm26
	vpmuludq ymm30, ymm27, ymm28
	vpmuludq ymm15, ymm11, ymm12
	vpmuludq ymm16, ymm13, ymm14
	vpmuludq ymm23, ymm19, ymm17
	vpaddd ymm31, ymm29, ymm30
	vpaddd ymm17, ymm15, ymm16
	vpaddq ymm2, ymm23, ymm24
	vpsllq ymm19, ymm17, 0x20
	vpcmpgtq ymm6, ymm5, ymm4
	vblendvpd ymm7, ymm4, ymm5, ymm6
	vpsllq ymm6, ymm31, 0x20
	vmovups ymmword ptr [rsi+0x60], ymm7
	vpaddq ymm7, ymm28, ymm26
	vpcmpgtq ymm3, ymm2, ymm1
	vpmuludq ymm5, ymm28, ymm26
	vpmuludq ymm18, ymm14, ymm12
	vblendvpd ymm4, ymm1, ymm2, ymm3
	vpaddq ymm8, ymm5, ymm6
	vpaddq ymm1, ymm18, ymm19
	vmovups ymmword ptr [rsi+0xa0], ymm4
	vpcmpgtq ymm9, ymm8, ymm7
	vpcmpgtq ymm2, ymm1, ymm0
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vblendvpd ymm3, ymm0, ymm1, ymm2
	vmovups ymmword ptr [rsi+0xc0], ymm10
	vmovups ymmword ptr [rsi+0xe0], ymm3
	add rsi, 0x100
	cmp r9d, r8d
	jb loop

	vzeroupper
	ret
