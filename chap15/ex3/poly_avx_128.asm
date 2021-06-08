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

;	.globl poly_avx_128

	; void poly_avx_128(float *in, float *out, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len

.code
poly_avx_128 PROC public

	push rbx

	mov rax, rcx   ; mov rax, pA
	mov rbx, rdx   ; mov rbx, pB
;	movsxd r8, edx ; movsxd r8, len
loop1:
	; Load A
	vmovups xmm0, [rax+r8*4]
	; A^2
	vmulps xmm1, xmm0, xmm0
	; A^3
	vmulps xmm2, xmm1, xmm0
	; A+A^2
	vaddps xmm0, xmm0, xmm1
	; A+A^2+A^3
	vaddps xmm0, xmm0, xmm2
	; Store result
	vmovups [rbx+r8*4], xmm0
	sub r8, 4
	jge loop1

	pop rbx
	ret
poly_avx_128 ENDP
end
