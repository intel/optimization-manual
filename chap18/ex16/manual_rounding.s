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

	.globl _manual_rounding
	.globl manual_rounding

	# void void manual_rounding(const float *a, const float *b, float* out);
	#
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = out

	.text

_manual_rounding:
manual_rounding:

	vmovups zmm2, [rdi]
	vmovups zmm4, [rsi]
	push rbx

	mov ebx, 0xffff
	kmovw k6, ebx

	sub rsp, 4
	mov rax, rsp
	sub rsp, 4
	mov rcx, rsp

	# rax & rcx point to temporary dword values in memory used to load and save (for restoring) MXCSR value exceptions

	vstmxcsr [rax] 			# load mxcsr value to memory
	mov ebx, [rax] 			# move to register
	and ebx, 0xFFFF9FFF 		# zero RM bits
	or ebx, 0x5F80			# put {ru} to RM bits and suppress all
	mov [rcx], ebx			# move new value to the memory
	vldmxcsr [rcx]			# save to MXCSR

	vaddps zmm7 {k6}, zmm2, zmm4 	# operation itself
	vldmxcsr [rax] 			# restore previous MXCSR value

	vmovups [rdx], zmm7

	add rsp, 8
	pop rbx
	vzeroupper
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
