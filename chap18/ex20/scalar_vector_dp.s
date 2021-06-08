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

	.globl _scalar_vector_dp
	.globl scalar_vector_dp

	# double scalar_vector_dp(const uint32_t *a_index, const double *a_value,
	#			  const uint32_t *b_index, const double *b_value,
	#			  uint64_t max_els);
	#
	# On entry:
	#     rdi = a_index
	#     rsi = a_value
	#     rdx = b_index
	#     rcx = b_value
	#     r8 = max_els

	.text

_scalar_vector_dp:
scalar_vector_dp:

	push rbx
	push r12
	push r13

	xchg rdx, rdi			# mov rdx, A_index
	xor rbx, rbx
	xchg rcx, rbx			# mov rcx, A_offset
	mov rax, rsi			# mov rax, A_value
	mov r12, rdi			# mov r12, B_index
	xor r13, r13			# mov r13, B_offset
					# mov rbx, B_value
	xorps xmm4, xmm4
loop:
	cmp rcx, r8
	jae end

	cmp r13, r8
	jae end

	mov r10d, dword ptr [rdx+rcx*4]
	mov r11d, dword ptr [r12+r13*4]
	cmp r10d, r11d
	jne skip_fma

	// do the fma on a match
	movsd xmm5, [rbx+r13*8]
	mulsd xmm5, [rax+rcx*8]
	addsd xmm4, xmm5
	inc rcx
	inc r13
	jmp loop

skip_fma:

	jae increment_b
	inc rcx
	jmp loop
increment_b:
	inc r13
	jmp loop

end:
	pop r13
	pop r12
	pop rbx

	movsd xmm0, xmm4

	ret
