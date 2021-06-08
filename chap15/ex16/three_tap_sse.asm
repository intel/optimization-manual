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

;	.globl three_tap_sse

	; void three_tap_sse(float *a, float *coeff, float *out, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = coeff
	;     r8 = out
	;     r9 = len


.code
three_tap_sse PROC public

	push rbx
;	push r15
	sub rsp, 16
	vmovaps xmmword ptr[rsp], xmm6

			      ; mov rcx, inPtr  (rcx already contains in)
;	mov r15, rdx          ; mov r15, coeffs
;	mov rdx, r8          ; mov rdx, outPtr
			      ; mov r9, len ( r9 already contains len )
	xor ebx, ebx
	movss xmm2, dword ptr[rdx]     ; load coeff 0
	shufps xmm2, xmm2, 0  ; broadcast coeff 0
	movss xmm1, dword ptr[rdx+4]   ; load coeff 1
	shufps xmm1, xmm1, 0  ; broadcast coeff 1
	movss xmm0, dword ptr[rdx+8]   ; coeff 2
	shufps xmm0, xmm0, 0  ; broadcast coeff 2
	movaps xmm5, [rcx]    ; xmm5={A[n+3],A[n+2],A[n+1],A[n]}

loop_start:
	movaps xmm6, [rcx+16] ; xmm6={A[n+7],A[n+6],A[n+5],A[n+4]}
	movaps xmm3, xmm6
	movaps xmm4, xmm6
	add rcx, 16           ; inPtr+=16
	add rbx, 4            ; loop counter
	palignr xmm3, xmm5, 4 ; xmm3={A[n+4],A[n+3],A[n+2],A[n+1]}
	palignr xmm4, xmm5, 8 ; xmm4={A[n+5],A[n+4],A[n+3],A[n+2]}
	mulps xmm5, xmm2      ; xmm5={C0*A[n+3],C0*A[n+2],C0*A[n+1], C0*A[n]}
	mulps xmm3, xmm1      ; xmm3={C1*A[n+4],C1*A[n+3],C1*A[n+2],C1*A[n+1]}
	mulps xmm4, xmm0      ; xmm4={C2*A[n+5],C2*A[n+4] C2*A[n+3],C2*A[n+2]}
	addps xmm3, xmm5
	addps xmm3, xmm4
	movaps [r8], xmm3
	movaps xmm5, xmm6
	add r8, 16           ; outPtr+=16
	cmp rbx, r9
	jl loop_start

	vmovaps xmm6, xmmword ptr[rsp]
;	pop r15
	add rsp, 16
	pop rbx
	ret
three_tap_sse ENDP
end