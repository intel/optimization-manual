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


;	.globl double_sqrt_14

	; void double_sqrt_14(double *a, double *out);
	; On entry:
	;     rcx = a
	;     rdx = out


.code
double_sqrt_14 PROC public

	vmovupd zmm0, [rcx]

	vrsqrt14pd zmm1, zmm0
	vfpclasspd k2, zmm0, 0eh
	knotw k3, k2
	vmulpd zmm0 {k3}, zmm0, zmm1

	vmovupd [rdx], zmm0

	vzeroupper

	ret
double_sqrt_14 ENDP
end