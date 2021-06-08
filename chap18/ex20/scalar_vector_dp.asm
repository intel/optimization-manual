;
; Copyright (C) 2021 by Intel Corporation
;
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
; REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
; AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
; INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
; LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
; OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
; PERFORMANCE OF THIS SOFTWARE.
;


;	.globl scalar_vector_dp

	; double scalar_vector_dp(const uint32_t *a_index, const double *a_value,
	;			  const uint32_t *b_index, const double *b_value,
	;			  uint64_t max_els);
	;
	; On entry:
	;     rcx rcx = a_index
	;     rdx = a_value
	;     r8 = b_index
	;     r9 = b_value
	;     [rsp+72] = max_els


.code
scalar_vector_dp PROC public

	push rbx
	push r12
	push r13
	push r14

	mov r14, [rsp+72]
	xchg r8, rcx			; mov r8, A_index
	xor rbx, rbx
	xchg r9, rbx			; mov r9, A_offset
	mov rax, rdx			; mov rax, A_value
	mov r12, rcx			; mov r12, B_index
	xor r13, r13			; mov r13, B_offset
					; mov rbx, B_value
	xorps xmm4, xmm4
loop1:
	cmp r9, r14
	jae end_loop

	cmp r13, r14
	jae end_loop

	mov r10d, dword ptr [r8+r9*4]
	mov r11d, dword ptr [r12+r13*4]
	cmp r10d, r11d
	jne skip_fma

;	// do the fma on a match
	movsd xmm5, QWORD PTR [rbx+r13*8]
	mulsd xmm5, QWORD PTR [rax+r9*8]
	addsd xmm4, xmm5
	inc r9
	inc r13
	jmp loop1

skip_fma:

	jae increment_b
	inc r9
	jmp loop1
increment_b:
	inc r13
	jmp loop1

end_loop:
	pop r14
	pop r13
	pop r12
	pop rbx

	movsd xmm0, xmm4

	ret
scalar_vector_dp ENDP
end