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
	
	;.globl poly_sse

	; void poly_sse(float *in, float *out, int32_t len);
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8d = len

	.code 
poly_sse PROC public

	push rbx

	mov rax, rcx   ; mov rax, pA
	mov rbx, rdx   ; mov rbx, pB
	movsxd r8, r8d ; movsxd r8, len
	sub r8, 4
loop1:
	; Load A
	movups xmm0, [rax+r8*4]
	; Copy A
	movups xmm1, [rax+r8*4]
	; A^2
	mulps xmm1, xmm1
	; Copy A^2
	movups xmm2, xmm1
	; A^3
	mulps xmm2, xmm0
	; A + A^2
	addps xmm0, xmm1
	; A + A^2 + A^3
	addps xmm0, xmm2
	; Store result
	movups [rbx+r8*4], xmm0
	sub r8, 4
	jge loop1

	pop rbx
	ret
poly_sse ENDP
end
