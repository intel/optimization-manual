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

;	.globl three_tap_avx

	; void three_tap_avx(float *a, float *coeff, float *out, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = coeff
	;     r8 = out
	;     r9 = len


.code
three_tap_avx PROC public

	push rbx
	sub rsp, 80
;	push r15
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10

	xor ebx, ebx

			                   ; mov rcx, inPtr  (rcx already contains in)
;	mov r15, rdx                       ; mov r15, coeffs
;	mov rdx, r8                        ; mov rdx, outPtr
			                   ; mov r9, len ( r9 already contains len )

	vbroadcastss ymm2, dword ptr[rdx]           ; load and broadcast coeff 0
	vbroadcastss ymm1, dword ptr[rdx+4]         ; load and broadcast coeff 1
	vbroadcastss ymm0, dword ptr[rdx+8]         ; load and broadcast coeff 2

loop_start:
	vmovaps ymm5, [rcx]                ; Ymm5={A[n+7],A[n+6],A[n+5],A[n+4];
	                                   ;  A[n+3],A[n+2],A[n+1] , A[n]}
	vshufps ymm6, ymm5, [rcx+16], 4eh ; ymm6={A[n+9],A[n+8],A[n+7],A[n+6];
	                                   ;  A[n+5],A[n+4],A[n+3],A[n+2]}
	vshufps ymm7, ymm5, ymm6, 99h     ; ymm7={A[n+8],A[n+7],A[n+6],A[n+5];
	                                   ;  A[n+4],A[n+3],A[n+2],A[n+1]}
	vmulps ymm3, ymm5, ymm2            ; ymm3={C0*A[n+7],C0*A[n+6],C0*A[n+5],C0*A[n+4];
	                                   ;  C0*A[n+3],C0*A[n+2],C0*A[n+1],C0*A[n]}
	vmulps ymm9, ymm7, ymm1            ; ymm9={C1*A[n+8],C1*A[n+7],C1*A[n+6],C1*A[n+5];
	                                   ;  C1*A[n+4],C1*A[n+3],C1*A[n+2],C1*A[n+1]}
	vmulps ymm4, ymm6, ymm0            ; ymm4={C2*A[n+9],C2*A[n+8],C2*A[n+7],C2*A[n+6];
	                                   ;  C2*A[n+5],C2*A[n+4],C2*A[n+3],C2*A[n+2]}
	vaddps ymm8, ymm3, ymm4
	vaddps ymm10, ymm8, ymm9
	vmovaps [r8], ymm10
	add rcx, 32                        ; inPtr+=32
	add rbx, 8                         ; loop counter
	add r8, 32                        ; outPtr+=32
	cmp rbx, r9
	jl loop_start

	vzeroupper
	vmovaps xmm10, xmmword ptr[rsp+64]
	vmovaps xmm9, xmmword ptr[rsp+48]
	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
;	pop r15
	add rsp, 80
	pop rbx
	ret
three_tap_avx ENDP
end