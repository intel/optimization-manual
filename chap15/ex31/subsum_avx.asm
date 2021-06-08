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

;	.globl subsum_avx

	; void subsum_avx(float *in, float *out, size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


.code
subsum_avx PROC public

	push rbx
	sub rsp, 112
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10
	vmovaps xmmword ptr[rsp+80], xmm11
	vmovaps xmmword ptr[rsp+96], xmm12

	mov rax, rcx
	mov rbx, rdx
	xor rcx, rcx

	vxorps ymm0, ymm0, ymm0
	vxorps ymm1, ymm1, ymm1
loop1:
	vmovaps ymm2, [rax+4*rcx]
	vshufps ymm4, ymm0, ymm2, 40h
	vshufps ymm3, ymm4, ymm2, 99h
	vshufps ymm5, ymm0, ymm4, 80h
	vaddps ymm6, ymm2, ymm3
	vaddps ymm7, ymm4, ymm5
	vaddps ymm9, ymm6, ymm7
	vaddps ymm1, ymm9, ymm1
	vshufps ymm8, ymm9, ymm9, 0ffh
	vperm2f128 ymm10, ymm8, ymm0, 2h
	vaddps ymm12, ymm1, ymm10
	vshufps ymm11, ymm12, ymm12, 0ffh
	vperm2f128 ymm1, ymm11, ymm11, 11h
	vmovaps [rbx+4*rcx], ymm12
	add rcx, 8
	cmp rcx, r8
	jl loop1

	vzeroupper
	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm9, xmmword ptr[rsp+48]
	vmovaps xmm10, xmmword ptr[rsp+64]
	vmovaps xmm11, xmmword ptr[rsp+80]
	vmovaps xmm12, xmmword ptr[rsp+96]
	add rsp, 112
	pop rbx

	ret
subsum_avx ENDP
end