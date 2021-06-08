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

	.globl _mce_avx2
	.globl mce_avx2

	# void mce_avx2(uint32_t *out, const uint32_t *in, uint64_t width)
	# On entry:
	#     rdi = out
	#     rsi = in
	#     rdx = width (must be > 0 and a multiple of 8)

	.text

_mce_avx2:
mce_avx2:

	push rbx

	                               # mov rsi, pImage
	                               # mov rdi, pOutImage
	mov rbx, rdx	               # mov rbx, [len]
	xor rax, rax

	vpbroadcastd ymm1, five[rip]   # vpbroadcastd ymm1, [five]
	vpbroadcastd ymm7, three[rip]  # vpbroadcastd ymm7, [three]
	vpxor ymm3, ymm3, ymm3
mainloop:
	vmovdqa ymm0, [rsi+rax*4]
	vmovaps ymm6, ymm0
	vpcmpgtd ymm5, ymm0, ymm3
	vpand ymm6, ymm6, ymm7
	vpcmpeqd ymm6, ymm6, ymm7
	vpand ymm5, ymm5, ymm6
	vpaddd ymm4, ymm0, ymm1
	vblendvps ymm4, ymm0, ymm4, ymm5
	vmovdqa [rdi+rax*4], ymm4
	add rax, 8
	cmp rax, rbx
	jne mainloop

	pop rbx
	vzeroupper

	ret

	.data
	.p2align 2

five:
	.int 5
three:
	.int 3

