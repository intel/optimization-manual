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

;	.globl divps_sse

	; void divps_sse(float *in1, float *in2, float *out, size_t len)
	; On entry:
	;     rcx = in1
	;     rdx = in2
	;     r8 = out
	;     r9 = len


.code
divps_sse PROC public

	push rbx

	mov rax, rcx
	mov rbx, rdx
	mov rdx, r9
	shl rdx, 2    ; rdx is size of inputs in bytes
	mov r9, r8
	xor r8, r8

loop1:
	movups xmm0, [rax+r8*1]
	movups xmm1, [rbx+r8*1]
	divps xmm0, xmm1
	movups [r9+r8*1], xmm0
	add r8, 16
	cmp r8, rdx
	jl loop1

	pop rbx
	ret
divps_sse ENDP
end