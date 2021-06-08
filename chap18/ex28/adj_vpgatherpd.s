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

	.globl _adj_vpgatherpd
	.globl adj_vpgatherpd

	# void adj_vpgatherpd(int64_t len, const int32_t *indices,
	#                     const elem_struct_t *elems, double *out);
	#     rdi = len
	#     rsi = indices
	#     rdx = elems
	#     rcx = out


	.text

_adj_vpgatherpd:
adj_vpgatherpd:

	vmovaps ymm0, index_inc[rip]
	vmovaps ymm1, index_scale[rip]
	mov eax, 0xf0
	kmovd k1, eax

	mov r9, rsi		# indices
	xor esi, esi
	mov r10, rdx
	mov r11, rcx

	push r15

loop:
	vpbroadcastd ymm3, [r9+rsi*4]
	mov r15d, esi
	vpbroadcastd xmm2, [r9+rsi*4+0x4]
	add rsi, 0x2
	vpbroadcastd ymm3{k1}, xmm2
	vpmulld ymm4, ymm3, ymm1
	vpaddd ymm5, ymm4, ymm0
	vpcmpeqb k2, xmm0, xmm0
	shl r15d, 0x2
	movsxd r15, r15d
	vpxord zmm6, zmm6, zmm6
	vgatherdpd zmm6{k2}, [r10+ymm5*1]
	vmovups [r11+r15*8], zmm6
	cmp rsi, rdi
	jl loop

	pop r15

	vzeroupper

	ret

	.data
	.p2align 5

index_inc:
	.4byte 0, 8, 16, 24, 0, 8, 16, 24
index_scale:
	.4byte 32, 32, 32, 32, 32, 32, 32, 32
