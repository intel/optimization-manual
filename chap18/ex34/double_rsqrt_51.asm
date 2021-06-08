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


;	.globl double_rsqrt_51

	; void double_rsqrt_51(double *a, double *out);
	; On entry:
	;     rcx = a
	;     rdx = out

	
	.data
	ALIGN 8

one	REAL8 1.0



.code
double_rsqrt_51 PROC public

	vmovupd zmm0, [rcx]
	vbroadcastsd zmm1, one

	vsqrtpd zmm0, zmm0
	vdivpd zmm0, zmm1, zmm0

	vmovupd [rdx], zmm0

	vzeroupper

	ret
double_rsqrt_51 ENDP
end