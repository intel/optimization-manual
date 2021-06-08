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


;	.globl fma_only_tpt

	; void fma_only_tpt(uint64_t loop_cnt);
	; On entry:
	;    rcx = loop_cnt

_RDATA SEGMENT    READ ALIGN(64) 'DATA'

one_vec REAL8 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0

_RDATA ENDS


.code
fma_only_tpt PROC public
	
	mov rdx, rsp
	and rsp, -10h
	sub rsp, 96
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10
	vmovaps xmmword ptr[rsp+80], xmm11

	vmovups zmm0, ZMMWORD PTR one_vec
	vmovups zmm1, ZMMWORD PTR one_vec
	vmovups zmm2, ZMMWORD PTR one_vec
	vmovups zmm3, ZMMWORD PTR one_vec
	vmovups zmm4, ZMMWORD PTR one_vec
	vmovups zmm5, ZMMWORD PTR one_vec
	vmovups zmm6, ZMMWORD PTR one_vec
	vmovups zmm7, ZMMWORD PTR one_vec
	vmovups zmm8, ZMMWORD PTR one_vec
	vmovups zmm9, ZMMWORD PTR one_vec
	vmovups zmm10, ZMMWORD PTR one_vec
	vmovups zmm11, ZMMWORD PTR one_vec
				; mov rcx, loops
loop1:
	vfmadd231pd zmm0, zmm0, zmm0
	vfmadd231pd zmm1, zmm1, zmm1
	vfmadd231pd zmm2, zmm2, zmm2
	vfmadd231pd zmm3, zmm3, zmm3
	vfmadd231pd zmm4, zmm4, zmm4
	vfmadd231pd zmm5, zmm5, zmm5
	vfmadd231pd zmm6, zmm6, zmm6
	vfmadd231pd zmm7, zmm7, zmm7
	vfmadd231pd zmm8, zmm8, zmm8
	vfmadd231pd zmm9, zmm9, zmm9
	vfmadd231pd zmm10, zmm10, zmm10
	vfmadd231pd zmm11, zmm11, zmm11
	dec rcx
	jg loop1

	vzeroupper

	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm9, xmmword ptr[rsp+48]
	vmovaps xmm10, xmmword ptr[rsp+64]
	vmovaps xmm11, xmmword ptr[rsp+80]
	mov rsp, rdx

	ret
fma_only_tpt ENDP
end