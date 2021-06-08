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

	.globl _memory_broadcast
	.globl memory_broadcast

	# void memory_broadcast(const uint16_t *input, uint16_t *output, uint64_t count,
	#                         uint16_t *broadcast, uint16_t *indices);
	# On entry:
	#     rdi = input
	#     rsi = output
	#     rdx = count
	#     rcx = broadcast
	#     r8  = indices

	.text

_memory_broadcast:
memory_broadcast:


	mov rax, rcx
	vmovdqu32 zmm3, [r8]
	vmovdqu32 zmm1, [rdi]

loop:
	vpbroadcastw zmm0, [rax]
	vpaddw zmm2, zmm1, zmm0
	vpermw zmm2, zmm3, zmm2
	add rax, 0x2
	sub rdx, 0x1
	jnz loop

	vmovdqu32 [rsi], zmm2
	vzeroupper
	ret
