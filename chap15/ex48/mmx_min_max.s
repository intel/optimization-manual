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

	.globl _mmx_min_max
	.globl mmx_min_max

	# void mmx_min_max(int16_t *in, min_max *out, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_mmx_min_max:
mmx_min_max:

	push rbx

	mov rax, rdi
	mov rbx, rsi
	mov r8, rdx
	mov rcx, 8
	movq mm0, [rax]
	movq mm1, [rax + 8]
	movq mm2, mm0
	movq mm3, mm1
	cmp rcx, r8
	jge end
loop:
	movq mm4, [rax + 2*rcx]
	movq mm5, [rax + 2*rcx + 8]
	pmaxsw mm0, mm4
	pmaxsw mm1, mm5
	pminsw mm2, mm4
	pminsw mm3, mm5
	add rcx, 8
	cmp rcx, r8
	jl loop
end:
	# Reduction
	pmaxsw mm0, mm1
	pshufw mm1, mm0, 0xE
	pmaxsw mm0, mm1
	pshufw mm1, mm0, 1
	pmaxsw mm0, mm1
	pminsw mm2, mm3
	pshufw mm3, mm2, 0xE
	pminsw mm2, mm3
	pshufw mm3, mm2, 1
	pminsw mm2, mm3
	movd eax, mm0
	mov WORD PTR [rbx], ax
	movd eax, mm2
	mov WORD PTR [rbx + 2], ax
	emms

	pop rbx

	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
