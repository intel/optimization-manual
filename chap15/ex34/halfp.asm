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

;	.globl halfp

	; void halfp(__m128i *x, __m128i *y, uint64_t len)
	; On entry:
	;     rcx = x
	;     rdx = y
	;     r8 = len

;	.set roundingCtrl, 0

.code
halfp PROC public

	push rbx
	sub rsp, 32
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7

;	mov rcx, r8
	xor rbx, rbx

	vcvtph2ps ymm0, xmmword ptr[rcx]
loop_start:
	add rcx,16
	vcvtph2ps ymm6, xmmword ptr[rcx]
	vperm2f128 ymm1, ymm0, ymm6, 21h
	vshufps ymm3, ymm0, ymm1, 4Eh
	vshufps ymm2, ymm0, ymm3, 99h
	vminps ymm5, ymm0, ymm2
	vmaxps ymm0, ymm0, ymm2
	vminps ymm4, ymm0, ymm3
	vmaxps ymm7, ymm4, ymm5
	vmovaps ymm0, ymm6
	vcvtps2ph xmmword ptr[rdx], ymm7, 0   ;roundingCtrl
	add rdx, 16
	add rbx, 8
	cmp rbx, r8
	jl loop_start

	vzeroupper
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 32
	pop rbx
	ret
halfp ENDP
end