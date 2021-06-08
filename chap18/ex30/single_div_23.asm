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


;	.globl single_div_23

	; void single_div_23(float *a, float *b, float *out);
	; On entry: 
	;     rcx = a
	;     rdx = b
	;     r8 = out


.code
single_div_23 PROC public

	vmovups zmm0, [rcx]
	vmovups zmm1, [rdx]

	vrcp14ps zmm2, zmm1
	vmulps zmm3, zmm0, zmm2
	vmovaps zmm4, zmm0
	vfnmadd231ps zmm4, zmm3, zmm1
	vfmadd231ps zmm3, zmm4, zmm2

	vmovups [r8], zmm3

	vzeroupper

	ret
single_div_23 ENDP
end