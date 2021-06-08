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


;	.globl double_rsqrt_50

	; void double_rsqrt_50(double *a, double *out);
	; On entry:
	;     rcx = a
	;     rdx = out

_RDATA SEGMENT    READ ALIGN(64) 'DATA'

one		DQ 03FF0000000000000h
		DQ 03FF0000000000000h
		DQ 03FF0000000000000h
		DQ 03FF0000000000000h
		DQ 03FF0000000000000h
		DQ 03FF0000000000000h
		DQ 03FF0000000000000h
		DQ 03FF0000000000000h
dc1		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
		DQ 03FE0000000000000h
dc2		DQ 03FD8000004600001h
		DQ 03FD8000004600001h
		DQ 03FD8000004600001h
		DQ 03FD8000004600001h
		DQ 03FD8000004600001h
		DQ 03FD8000004600001h
		DQ 03FD8000004600001h
		DQ 03FD8000004600001h
dc3		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h

_RDATA ENDS


.code
double_rsqrt_50 PROC public

	sub rsp, 56
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8


	vmovupd zmm3, [rcx]
	vmovupd zmm5, one		; vmovapd zmm5, One
	vmovupd zmm6, dc1		; vmovapd zmm6, dc1
	vmovupd zmm8, dc3		; vmovapd zmm8, dc3
	vmovupd zmm7, dc2		; vmovapd zmm7, dc2

	vrsqrt14pd zmm2, zmm3
	vfpclasspd k1, zmm3, 05eh	; vfpclasspd k1, zmm3, 5eh
	vmulpd zmm0, zmm2, zmm3 {rn-sae}
	vfnmadd231pd zmm0, zmm2, zmm5
	vmulpd zmm1, zmm2, zmm0
	vmovapd zmm4, zmm8
	vfmadd213pd zmm4, zmm0, zmm7
	vfmadd213pd zmm4, zmm0, zmm6
	vfmadd213pd zmm4, zmm1, zmm2
	vorpd zmm4{k1}, zmm2, zmm2

	vmovupd [rdx], zmm4

	vzeroupper

	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 56

	ret

double_rsqrt_50 ENDP
end