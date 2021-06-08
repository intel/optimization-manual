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


;	.globl double_div_52

	; void double_div_52(double *a, double *a, double *out);
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = out

	.data
	ALIGN 8

one	 REAL8 1.0


.code
double_div_52 PROC public

	vmovupd zmm5, [rcx]
	vmovupd zmm0, [rdx]

	vrcp14pd zmm1, zmm0
	vmovapd zmm4, zmm0
	vbroadcastsd zmm2, one		; vbroadcastsd zmm2, One
	vfnmadd213pd zmm0, zmm1, zmm2 {rn-sae}
	vfpclasspd k2, zmm1, 01eh		; vfpclasspd k2, zmm1, 1eh
	vfmadd213pd zmm0, zmm1, zmm1 {rn-sae}
	knotw k3, k2
	vfnmadd213pd zmm4, zmm0, zmm2 {rn-sae}
	vblendmpd zmm0 {k2}, zmm0, zmm1
	vfmadd213pd zmm0 {k3}, zmm4, zmm0 {rn-sae}
	vmulpd zmm0, zmm0, zmm5

	vmovupd [r8], zmm0

	vzeroupper

	ret

double_div_52 ENDP
end