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

	.globl _register_broadcast
	.globl register_broadcast

	# void register_broadcast(const uint32_t *input, uint32_t *output, uint64_t count,
	#                         uint32_t *broadcast, uint32_t *indices);
	# On entry:
	#     rdi = input
	#     rsi = output
	#     rdx = count
	#     rcx = broadcast
	#     r8  = indices

	.text

_register_broadcast:
register_broadcast:


	mov rax, rcx
	vmovdqu32 zmm3, [r8]
	vmovdqu32 zmm1, [rdi]

loop:
	vmovd xmm0, [rax]
	vpbroadcastd zmm0, xmm0
	vpaddd zmm2, zmm1, zmm0
	vpermd zmm2, zmm3, zmm2
	add rax, 0x4
	sub rdx, 0x1
	jnz loop

	vmovdqu32 [rsi], zmm2
	vzeroupper
	ret
