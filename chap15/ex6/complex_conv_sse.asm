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

;	.globl complex_conv_sse

	; void complex_conv_sse(complex_num *complex_buffer, float *real_buffer, float *imaginary_buffer, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = out1
	;     r8 = out2
	;     r9 = len

.code
complex_conv_sse PROC public

	push rbx

	xor rbx, rbx
	mov rax, r8 ;	mov rax, outPtr2
	xor r8, r8

	; rcx and rdx are already initialised correctly.
	; r9 needs to be multiplied by 8
	; mov r9, len
	shl r9, 3
	; mov rcx, inPtr
	; mov rdx, outPtr1

loop1:
	movups xmm0, [rcx+rbx] ; i1 r1 i0 r0
	movups xmm1, [rcx+rbx+16] ;  i3 r3 i2 r2
	movups xmm2, xmm0
	shufps xmm0, xmm1, 221 ; i3 i2 i1 i0
	shufps xmm2, xmm1, 136 ; r3 r2 r1 r0
	movups [rax+r8], xmm0
	movups [rdx+r8], xmm2
	add r8, 16
	add rbx, 32
	cmp r9, rbx
	jnz loop1

	pop rbx
	ret
complex_conv_sse ENDP
end
