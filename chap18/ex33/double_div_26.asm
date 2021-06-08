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


;	.globl double_div_26

	; void double_div_26(double *a, double *b, double *out);
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = out


.code
double_div_26 PROC public

	vmovupd zmm0, [rcx]
	vmovupd zmm1, [rdx]

	vrcp14pd zmm2, zmm1
	vmulpd zmm3, zmm0, zmm2
	vmovapd zmm4, zmm0
	vfnmadd231pd zmm4, zmm3, zmm1
	vfmadd231pd zmm3, zmm4, zmm2


	vmovupd [r8], zmm3

	vzeroupper

	ret
double_div_26 ENDP
end