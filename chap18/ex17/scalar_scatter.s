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

	.globl _scalar_scatter
	.globl scalar_scatter

	# void scalar_scatter(const uint64_t *input, const uint32_t *indices, uint64_t count, float *output);
	#
	# On entry:
	#     rdi = input
	#     rsi = indices
	#     rdx = count
	#     rcx = output

	.text

_scalar_scatter:
scalar_scatter:

	push rbx

	mov rax, rdi					# mov rax, pImage // input
							# mov rcx, pOutImage //output
	mov rbx, rsi					# mov rbx, pIndex //indexes
							# mov rdx, len //length

	xor r9, r9

mainloop:
	mov r9d, [rbx+rdx-0x4]
	vcvtsi2ss xmm0, xmm0, qword ptr [rax+rdx*2-0x8]
	vmovss [rcx+r9*4], xmm0
	sub rdx, 4
	jnz mainloop

	pop rbx
	ret
