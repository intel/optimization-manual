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


;	.globl single_rcps_23

	; void single_rcps_23(float *a, float *out);
	; On entry:
	;     rcx = a
	;     rdx = out

	.data
	ALIGN 4

half REAL4 0.5f



.code
single_rcps_23 PROC public

	vmovups zmm0, [rcx]

	vbroadcastss zmm1, half		; zmm1 = vector of 16 0.5s
	vrsqrt14ps zmm2, zmm0
	vmulps zmm3, zmm0, zmm2
	vmulps zmm4, zmm1, zmm2
	vfnmadd231ps zmm1, zmm3, zmm4
	vfmsub231ps zmm3, zmm0, zmm2
	vfnmadd231ps zmm1, zmm4, zmm3
	vfmadd231ps zmm2, zmm2, zmm1

	vmovups [rdx], zmm2

	vzeroupper

	ret

single_rcps_23 ENDP
end