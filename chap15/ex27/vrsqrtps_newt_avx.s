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

	.globl _vrsqrtps_newt_avx
	.globl vrsqrtps_newt_avx

	# void vrsqrtps_newt_avx(float *in, float *out, size_t len)
	# On entry:
	#     rdi = in
	#     rsi = out
	#     rdx = len

	.text

_vrsqrtps_newt_avx:
vrsqrtps_newt_avx:

	push rbx
	
	mov rax, rdi
	mov rbx, rsi
	mov rcx, rdx
	shl rcx, 2    # rcx is size of inputs in bytes
	xor rdx, rdx

	vmovups ymm3, three[rip]
	vmovups ymm4, half[rip]

loop1:
	vmovups ymm5, [rax+rdx]
	vrsqrtps ymm0, ymm5
	vmulps ymm2, ymm0, ymm0
	vmulps ymm2, ymm2, ymm5
	vsubps ymm2, ymm3, ymm2
	vmulps ymm0, ymm0, ymm2
	vmulps ymm0, ymm0, ymm4
	vmovups [rbx+rdx], ymm0
	add rdx, 32
	cmp rdx, rcx
	jl loop1	

	vzeroupper
	pop rbx
	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 5

half:
	.float 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5

three:
	.float 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
