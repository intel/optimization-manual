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


;	.globl double_sqrt_26

	; void double_sqrt_26(double *a, double *out);
	; On entry:
	;     rcx = a
	;     rdx = out

	
_RDATA SEGMENT    READ ALIGN(64) 'DATA'

half	DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h

_RDATA ENDS


.code
double_sqrt_26 PROC public

	vmovupd zmm0, [rcx]

	vrsqrt14pd zmm1, zmm0
	vfpclasspd k2, zmm0, 0eh		; vfpclasspd k2, zmm0, 0eh
	knotw k3, k2
	vmulpd zmm0 {k3}, zmm0, zmm1
	vmulpd zmm1, zmm1, half		; vmulpd zmm1, zmm1, ZMMWORD PTR [OneHalf]
	vfnmadd213pd zmm1, zmm0, half	; vfnmadd213pd zmm1, zmm0, ZMMWORD PTR [OneHalf]
	vfmadd213pd zmm0 {k3}, zmm1, zmm0

	vmovupd [rdx], zmm0

	vzeroupper

	ret
double_sqrt_26 ENDP
end