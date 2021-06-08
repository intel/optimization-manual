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

;	.globl cond_scalar

	; void cond_scalar(float *a, float *b, float *d, float *c, float *e, size_t len);
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = d
	;     r9 = c
	;     [rsp+48] = e
	;     [rsp+56] = len

.code
cond_scalar PROC public
	push rbx

	mov rax, rcx                      ; mov rax, pA
;	mov rbx, rdx                      ; mov rbx, pB
	                                  ; mov rcx, pC
	                                  ; mov rdx, pD
	mov rbx, qword ptr[rsp+48]        ; mov rbx, pE
	mov r11, qword ptr[rsp+56]        ; mov r11, len
	shl r11, 2                        ; each element occupies 4 bytes

	; xmm0 all zeros
	vxorps xmm0, xmm0, xmm0
	xor r10, r10
loop1:
	vmovss xmm1, dword ptr[rax+r10]
	vcomiss xmm1, xmm0
	jbe a_le
a_gt:
	vmovss xmm4, dword ptr[r9+r10]
	jmp mul1
a_le:
	vmovss xmm4, dword ptr[r8+r10]
mul1:
	vmulss xmm4, xmm4, dword ptr[rbx+r10]
	vmovss dword ptr[rdx+r10], xmm4
	add r10, 4
	cmp r10, r11
	jl loop1

	pop rbx
	ret
cond_scalar ENDP
end