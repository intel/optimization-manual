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


;	.globl fma_shuffle_tpt

	; void fma_shuffle_tpt(uint64_t loop_cnt);
	; On entry:
	;     rcx = loop_cnt


_RDATA SEGMENT    READ ALIGN(64) 'DATA'

one_vec REAL8 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
shuf_vec DD 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

_RDATA ENDS


.code
fma_shuffle_tpt PROC public

	mov rdx, rsp
	and rsp, -10h
	sub rsp, 160
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10
	vmovaps xmmword ptr[rsp+80], xmm11
	vmovaps xmmword ptr[rsp+96], xmm12
	vmovaps xmmword ptr[rsp+112], xmm13
	vmovaps xmmword ptr[rsp+128], xmm14
	vmovaps xmmword ptr[rsp+144], xmm15

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
	vmovups zmm12, ZMMWORD PTR shuf_vec
	vmovups zmm13, ZMMWORD PTR shuf_vec
	vmovups zmm14, ZMMWORD PTR shuf_vec
	vmovups zmm15, ZMMWORD PTR shuf_vec
	vmovups zmm16, ZMMWORD PTR shuf_vec
	vmovups zmm17, ZMMWORD PTR shuf_vec
	vmovups zmm18, ZMMWORD PTR shuf_vec
	vmovups zmm19, ZMMWORD PTR shuf_vec
	vmovups zmm20, ZMMWORD PTR shuf_vec
	vmovups zmm21, ZMMWORD PTR shuf_vec
	vmovups zmm22, ZMMWORD PTR shuf_vec
	vmovups zmm23, ZMMWORD PTR shuf_vec
	vmovups zmm30, ZMMWORD PTR shuf_vec
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
	vpermd zmm12, zmm30, zmm30
	vpermd zmm13, zmm30, zmm30
	vpermd zmm14, zmm30, zmm30
	vpermd zmm15, zmm30, zmm30
	vpermd zmm16, zmm30, zmm30
	vpermd zmm17, zmm30, zmm30
	vpermd zmm18, zmm30, zmm30
	vpermd zmm19, zmm30, zmm30
	vpermd zmm20, zmm30, zmm30
	vpermd zmm21, zmm30, zmm30
	vpermd zmm22, zmm30, zmm30
	vpermd zmm23, zmm30, zmm30
	dec rcx
	jg loop1

	vzeroupper

	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm9, xmmword ptr[rsp+48]
	vmovaps xmm10, xmmword ptr[rsp+64]
	vmovaps xmm11, xmmword ptr[rsp+80]
	vmovaps xmm12, xmmword ptr[rsp+96]
	vmovaps xmm13, xmmword ptr[rsp+112]
	vmovaps xmm14, xmmword ptr[rsp+128]
	vmovaps xmm15, xmmword ptr[rsp+144]
	
	mov rsp, rdx

	ret
fma_shuffle_tpt ENDP
end