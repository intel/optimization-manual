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


;	.globl double_rsqrt_26

	; void double_rsqrt_26(double *a, double *out);
	; On entry:
	;     rcx = a
	;     rdx = out
	
	.data
	ALIGN 8

half	REAL8 0.5



.code
double_rsqrt_26 PROC public

	vmovupd zmm0, [rcx]

	vrsqrt14pd zmm1, zmm0
	vmulpd zmm0, zmm0, zmm1
	vbroadcastsd zmm3, half			; vbroadcastsd zmm3, half
	vmulpd zmm2, zmm1, zmm3
	vfnmadd213pd zmm2, zmm0, zmm3
	vfmadd213pd zmm1, zmm2, zmm1

	vmovupd [rdx], zmm1

	vzeroupper

	ret

double_rsqrt_26 ENDP
end