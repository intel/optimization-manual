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

;	.globl median_sse

	; void median_sse(float *x, float *y, uint64_t len);
	; On entry:
	;    rcx = x
	;    rdx = y
	;    r8 = len

.code
median_sse PROC public

	push rbx

	xor ebx, ebx
	;mov rcx, rdx   ; mov rcx, len

	; rcx and rdx already point to x and y the inputs and outputs
	; mov rcx, inPtr
	; mov rdx, outPtr

	movaps xmm0, [rcx]
loop_start:
	movaps xmm4, [rcx+16]
	movaps xmm2, [rcx]
	movaps xmm1, [rcx]
	movaps xmm3, [rcx]
	add rcx, 16
	add rbx, 4
	shufps xmm2, xmm4, 4Eh
	shufps xmm1, xmm2, 99h
	minps xmm3, xmm1
	maxps xmm0, xmm1
	minps xmm0, xmm2
	maxps xmm0, xmm3
	movaps [rdx], xmm0
	movaps xmm0, xmm4
	add rdx, 16
	cmp rbx, r8
	jl loop_start

	pop rbx
	ret
median_sse ENDP
end
