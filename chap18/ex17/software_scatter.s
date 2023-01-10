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

	.globl _software_scatter
	.globl software_scatter

	# void software_scatter(const uint64_t *input, const uint32_t *indices, uint64_t count, float *output);
	#
	# On entry:
	#     rdi = input
	#     rsi = indices
	#     rdx = count
	#     rcx = output

	.text

_software_scatter:
software_scatter:

	push rbx

	mov rax, rdi					# mov rax, pImage // input
							# mov rcx, pOutImage //output
	mov rbx, rsi					# mov rbx, pIndex //indexes
							# mov rdx, len //length


	lea r9, shufMaskP[rip]				# mov r9, shufMaskP
	vmovaps ymm2, [r9]

mainloop:
	vmovaps zmm1, [rax + rdx*2 - 0x80] 		# load data
	vcvtuqq2ps ymm0, zmm1 				# convert to float
	movsxd r9, [rbx + rdx - 0x40] 			# load 8th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x3c] 			# load 7th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x38] 			# load 6th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x34] 			# load 5th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x30]			# load 4th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x2c] 			# load 3rd index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x28] 			# load 2nd index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x24] 			# load 1st index
	vmovss [rcx + 4*r9], xmm0
	vmovaps zmm1, [rax + rdx*2 - 0x40] 		# load data
	vcvtuqq2ps ymm0, zmm1 				# convert to float
	movsxd r9, [rbx + rdx - 0x20] 			# load 8th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x1c] 			# load 7th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x18] 			# load 6th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x14] 			# load 5th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x10] 			# load 4th index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0xc] 			# load 3rd index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x8] 			# load 2nd index
	vmovss [rcx + 4*r9], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r9, [rbx + rdx - 0x4]			# load 1st index
	vmovss [rcx + 4*r9], xmm0
	sub rdx, 0x40
	jnz mainloop

	vzeroupper
	pop rbx
	ret

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 5

	shufMaskP:
	.quad 0x0000000200000001
	.quad 0x0000000400000003
	.quad 0x0000000600000005
	.quad 0x0000000800000007

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
