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

	.globl _hardware_scatter
	.globl hardware_scatter

	# void hardware_scatter(const uint64_t *input, const uint32_t *indices, uint64_t count, float *output);
	#
	# On entry:
	#     rdi = input
	#     rsi = indices
	#     rdx = count
	#     rcx = output

	.text

_hardware_scatter:
hardware_scatter:

	push rbx

	mov rax, rdi					# mov rax, pImage // input
							# mov rcx, pOutImage //output
	mov rbx, rsi					# mov rbx, pIndex //indexes
							# mov rdx, len //length

mainloop:
	vmovdqa32 zmm0, [rbx+rdx-0x40]
	vmovdqa32 zmm1, [rax+rdx*2-0x80]
	vcvtuqq2ps ymm1, zmm1
	vmovdqa32 zmm2, [rax+rdx*2-0x40]
	vcvtuqq2ps ymm2, zmm2
	vshuff32x4 zmm1, zmm1, zmm2, 0x44
	kxnorw k1,k1,k1
	vscatterdps [rcx+4*zmm0] {k1}, zmm1
	sub rdx, 0x40
	jnz mainloop

	vzeroupper
	pop rbx
	ret
