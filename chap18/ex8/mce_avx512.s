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

	.globl _mce_avx512
	.globl mce_avx512

	# void mce_avx512(uint32_t *out, const uint32_t *in, uint64_t width)
	# On entry:
	#     rdi = out
	#     rsi = in
	#     rdx = width (must be > 0 and a multiple of 16)

	.text

_mce_avx512:
mce_avx512:

	push rbx

	                               # mov rsi, pImage
	                               # mov rdi, pOutImage
	mov rbx, rdx	               # mov rbx, [len]
	xor rax, rax

	vpbroadcastd zmm1, five[rip]
	vpbroadcastd zmm5, three[rip]
	vpxord zmm3, zmm3, zmm3
mainloop:
	vmovdqa32 zmm0, [rsi+rax*4]
	vpcmpgtd k1, zmm0, zmm3
	vpandd zmm6, zmm5, zmm0
	vpcmpeqd k2, zmm6, zmm5
	kandw k1, k2, k1
	vpaddd zmm0 {k1}, zmm0, zmm1
	vmovdqa32 [rdi+rax*4], zmm0
	add rax, 16
	cmp rax, rbx
	jne mainloop

	pop rbx
	vzeroupper

	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 2

five:
	.int 5
three:
	.int 3

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
