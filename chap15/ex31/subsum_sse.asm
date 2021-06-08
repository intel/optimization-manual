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

;	.globl subsum_sse

	; void subsum_sse(float *in, float *out, size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


.code
subsum_sse PROC public

	push rbx

	mov rax, rcx
	mov rbx, rdx
	xor rcx, rcx

	xor rcx, rcx
	xorps xmm0, xmm0
loop1:
	movaps xmm2, [rax+4*rcx]
	movaps xmm3, [rax+4*rcx]
	movaps xmm4, [rax+4*rcx]
	movaps xmm5, [rax+4*rcx]
	pslldq xmm3, 4
	pslldq xmm4, 8
	pslldq xmm5, 12
	addps xmm2, xmm3
	addps xmm4, xmm5
	addps xmm2, xmm4
	addps xmm2, xmm0
	movaps xmm0, xmm2
	shufps xmm0, xmm2, 0FFh
	movaps [rbx+4*rcx], xmm2
	add rcx, 4
	cmp rcx, r8
	jl loop1

	pop rbx
	ret
subsum_sse ENDP
end
