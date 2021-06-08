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

;	.globl rsqrtps_newt_sse

	; void rsqrtps_newt_sse(float *in, float *out, size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len

	.data
	ALIGN 16

minus_half REAL4 -0.5, -0.5, -0.5, -0.5

three REAL4 3.0, 3.0, 3.0, 3.0

.code
rsqrtps_newt_sse PROC public

	push rbx

	mov rax, rcx
	mov rbx, rdx
	mov rcx, r8
	shl rcx, 2    ; rcx is size of inputs in bytes
	xor r8, r8

	movups xmm3, xmmword ptr three
	movups xmm4, xmmword ptr minus_half
loop1:
	movups xmm5, [rax+r8]
	rsqrtps xmm0, xmm5
	movaps xmm2, xmm0
	mulps xmm0, xmm0
	mulps xmm0, xmm5
	subps xmm0, xmm3
	mulps xmm0, xmm2
	mulps xmm0, xmm4
	movups [rbx+r8], xmm0
	add r8, 16
	cmp r8, rcx
	jl loop1
	pop rbx
	ret
rsqrtps_newt_sse ENDP
end