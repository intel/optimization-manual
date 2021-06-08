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

;	.globl sqrt_vrsqrtps_taylor_avx

	; void sqrt_vrsqrtps_taylor_avx(float *in, float *out, size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


_RDATA SEGMENT    READ ALIGN(32) 'DATA'

minus_half REAL4 -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5
three REAL4 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0

_RDATA ENDS

.code
sqrt_vrsqrtps_taylor_avx PROC public

	push rbx
	sub rsp, 32
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7

	mov rax, rcx
	mov rbx, rdx
	mov rcx, r8
	shl rcx, 2    ; rcx is size of inputs in bytes
	xor r8, r8

	vmovups ymm6, three
	vmovups ymm7, minus_half
	vxorps ymm5, ymm5, ymm5
loop1:
	vmovups ymm3, [rax+r8]
	vrsqrtps ymm4, ymm3
	vcmpneqps ymm0, ymm5, ymm3
	vandps ymm4, ymm4, ymm0
	vmulps ymm1,ymm4, ymm3
	vmulps ymm2, ymm1, ymm4
	vsubps ymm2, ymm2, ymm6
	vmulps ymm1, ymm1, ymm2
	vmulps ymm1, ymm1, ymm7
	vmovups [rbx+r8], ymm1
	add r8, 32
	cmp r8, rcx
	jl loop1

	vzeroupper
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 32
	pop rbx
	ret
sqrt_vrsqrtps_taylor_avx ENDP
end