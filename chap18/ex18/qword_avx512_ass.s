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

	.globl _qword_avx512_ass
	.globl qword_avx512_ass

	# void qword_avx512_ass(const int64_t *a, const int64_t *b, int64_t *c, uint64_t count);
	#
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = c
	#     rcx = count

	.text

_qword_avx512_ass:
qword_avx512_ass:

	mov rax, rdi
	mov r11, rsi
	mov rsi, rdx
	mov r8, rcx
	shr r8, 5
	xor rcx, rcx
	xor r9d, r9d

loop:
	vmovups zmm0, zmmword ptr [rax+rcx*8]
	inc r9d
	vmovups zmm5, zmmword ptr [rax+rcx*8+0x40]
	vmovups zmm10, zmmword ptr [rax+rcx*8+0x80]
	vmovups zmm15, zmmword ptr [rax+rcx*8+0xc0]
	vmovups zmm1, zmmword ptr [r11+rcx*8]
	vmovups zmm6, zmmword ptr [r11+rcx*8+0x40]
	vmovups zmm11, zmmword ptr [r11+rcx*8+0x80]
	vmovups zmm16, zmmword ptr [r11+rcx*8+0xc0]
	vpaddq zmm2, zmm0, zmm1
	vpmullq zmm3, zmm0, zmm1
	vpaddq zmm7, zmm5, zmm6
	vpmullq zmm8, zmm5, zmm6
	vpaddq zmm12, zmm10, zmm11
	vpmullq zmm13, zmm10, zmm11
	vpaddq zmm17, zmm15, zmm16
	vpmullq zmm18, zmm15, zmm16
	vpmaxsq zmm4, zmm2, zmm3
	vpmaxsq zmm9, zmm7, zmm8
	vpmaxsq zmm14, zmm12, zmm13
	vpmaxsq zmm19, zmm17, zmm18
	vmovups zmmword ptr [rsi], zmm4
	vmovups zmmword ptr [rsi+0x40], zmm9
	vmovups zmmword ptr [rsi+0x80], zmm14
	vmovups zmmword ptr [rsi+0xc0], zmm19
	add rcx, 0x20
	add rsi, 0x100
	cmp r9d, r8d
	jb loop

	vzeroupper
	ret
