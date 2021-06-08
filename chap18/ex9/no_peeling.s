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

	.globl _no_peeling
	.globl no_peeling

	# void no_peeling(float *out, const float *in, uint64_t width, float add_value, float alfa);
	# On entry:
	#     rdi = out
	#     rsi = in
	#     rdx = width

	.text

_no_peeling:
no_peeling:

	push rbx

	mov rbx, rdi               # mov rbx, pOutImage ( Output )
	mov rax, rsi               # mov rax, pImage ( Input )
	mov rcx, rdx               # mov rcx, len
	                           # movss xmm0, addValue
	vpbroadcastd zmm0, xmm0
	                           # movss xmm1, alfa
	vpbroadcastd zmm3, xmm1
	mov rdx, rcx
	sar rdx, 4                 # 16 elements per iteration, RDX - number of full iterations
	jz remainder               # no full iterations
	xor r8, r8
	vmovups zmm10, indices[rip]
mainloop:
	vmovups zmm1, [rax + r8]
	vfmadd213ps zmm1, zmm3, zmm0
	vmovups [rbx + r8], zmm1
	add r8, 0x40
	sub rdx, 1
	jne mainloop
remainder:
	# produce mask for remainder
	and rcx, 0xF               # number of elements in remainder
	jz end                     # no elements in remainder
	vpbroadcastd zmm2, ecx
	vpcmpd k2, zmm10, zmm2, 1  # compare lower
	vmovups zmm1 {k2}{z}, [rax + r8]
	vfmadd213ps zmm1 {k2}{z}, zmm3, zmm0
	vmovups [rbx + r8] {k2}, zmm1
end:

	pop rbx
	vzeroupper

	ret

	.data
	.p2align 6

indices:
	.int 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
