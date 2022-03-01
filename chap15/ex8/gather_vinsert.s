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

	.globl _gather_vinsert
	.globl gather_vinsert

	# void gather_vinsert(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = index
	#     rcx = len

	.text
_gather_vinsert:
gather_vinsert:

	push rbx

	# registers are already initialised correctly.
	# mov rdi, InBuf
	# mov rsi, OutBuf
	# mov rdx, Index
	mov r8, rcx

	xor rcx, rcx
loop1:
	mov rax, [rdx + 4*rcx]
	movsxd rbx, eax
	sar rax, 32
	vmovss xmm1, [rdi + 4*rbx]
	vinsertps xmm1, xmm1, [rdi + 4*rax], 0x10
	mov rax, [rdx + 8 + 4*rcx]
	movsxd rbx, eax
	sar rax, 32
	vinsertps xmm1, xmm1, [rdi + 4*rbx], 0x20
	vinsertps xmm1, xmm1, [rdi + 4*rax], 0x30
	mov rax, [rdx + 16 + 4*rcx]
	movsxd rbx, eax
	sar rax, 32
	vmovss xmm2, [rdi + 4*rbx]
	vinsertps xmm2, xmm2, [rdi + 4*rax], 0x10
	mov rax,[rdx + 24 + 4*rcx]
	movsxd rbx, eax
	sar rax, 32
	vinsertps xmm2, xmm2, [rdi + 4*rbx], 0x20
	vinsertps xmm2, xmm2, [rdi + 4*rax], 0x30
	vinsertf128 ymm1, ymm1, xmm2, 1
	vmovaps [rsi + 4*rcx], ymm1
	add rcx, 8
	cmp rcx, r8 # cmp rcx, len
	jl loop1

	vzeroupper
	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
