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

#define M 4
#define N 96
#define K_PACK 2
#define I_STRIDE N * 2
#define O_STRIDE N * 2 * K_PACK

	.intel_syntax noprefix

	.globl _flat_to_vnni_bf16_relayout
	.globl flat_to_vnni_bf16_relayout

	# void flat_to_vnni_bf16_relayout(const bfloat_16 *input, bfloat_16 *output);
	# On entry:
	#     rdi = input
	#     rsi = output

	.text

_flat_to_vnni_bf16_relayout:
flat_to_vnni_bf16_relayout:

	mov r8, rdi
	mov r9, rsi
	vmovdqa32 zmm30, perm_cnt1[rip]
	vmovdqa32 zmm31, perm_cnt2[rip]

	mov rdx, M / 2
L_M:
	mov rax, N / 32
L_N:
	vmovups zmm0, zmmword ptr [r8]
	vmovups zmm1, zmmword ptr [r8+I_STRIDE]

	vmovups zmm2, zmm0
	vpermt2w zmm2, zmm30, zmm1
	vpermt2w zmm1, zmm31, zmm0

	vmovups zmmword ptr [r9], zmm2
	vmovups zmmword ptr [r9+0x40], zmm1

	add r9, 0x80
	add r8, 0x40
	dec rax
	jnz L_N
        add r9, (O_STRIDE - (N/32)*0x80)
        add r8, (I_STRIDE*2 - (N/32)*0x40)
	dec rdx
	jnz L_M

	vzeroupper
	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
.p2align 6

perm_cnt1:
	.short 0x00, 0x20, 0x01, 0x21, 0x02, 0x22, 0x03, 0x23
	.short 0x04, 0x24, 0x05, 0x25, 0x06, 0x26, 0x07, 0x27
	.short 0x08, 0x28, 0x09, 0x29, 0x0a, 0x2a, 0x0b, 0x2b
	.short 0x0c, 0x2c, 0x0d, 0x2d, 0x0e, 0x2e, 0x0f, 0x2f
perm_cnt2:
	.short 0x30, 0x10, 0x31, 0x11, 0x32, 0x12, 0x33, 0x13
	.short 0x34, 0x14, 0x35, 0x15, 0x36, 0x16, 0x37, 0x17
	.short 0x38, 0x18, 0x39, 0x19, 0x3a, 0x1a, 0x3b, 0x1b
	.short 0x3c, 0x1c, 0x3d, 0x1d, 0x3e, 0x1e, 0x3f, 0x1f

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
