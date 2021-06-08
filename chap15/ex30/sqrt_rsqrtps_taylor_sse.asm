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

;	.globl sqrt_rsqrtps_taylor_sse

	; void sqrt_rsqrtps_taylor_sse(float *in, float *out, size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


	.data
	ALIGN 16
minus_half REAL4 -0.5, -0.5, -0.5, -0.5
three REAL4 3.0, 3.0, 3.0, 3.0

.code
sqrt_rsqrtps_taylor_sse PROC public

	push rbx
	sub rsp, 16
	vmovaps xmmword ptr[rsp], xmm6

	mov rax, rcx
	mov rbx, rdx
	mov rcx, r8
	shl rcx, 2    ; rcx is size of inputs in bytes
	xor r8, r8

	movups xmm6, xmmword ptr three
	movups xmm2, xmmword ptr minus_half

loop1:
	movups xmm3, [rax+r8]
	rsqrtps xmm1, xmm3
	xorps xmm0, xmm0
	cmpneqps xmm0, xmm3
	andps xmm1, xmm0
	movaps xmm4, xmm1
	mulps xmm1, xmm3
	movaps xmm5, xmm1
	mulps xmm1, xmm4
	subps xmm1, xmm6
	mulps xmm1, xmm5
	mulps xmm1, xmm2
	movups [rbx+r8], xmm1
	add r8, 16
	cmp r8, rcx
	jl loop1

	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 16
	pop rbx
	ret
sqrt_rsqrtps_taylor_sse ENDP
end