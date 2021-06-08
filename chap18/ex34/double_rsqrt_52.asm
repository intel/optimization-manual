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


;	.globl double_rsqrt_52

	; void double_rsqrt_52(double *a, double *out);
	; On entry:
	;     rcx = a
	;     rdx = out

	
_RDATA SEGMENT    READ ALIGN(64) 'DATA'

one 	DQ 03FF0000000000000h
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
dc3 	DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h
		DQ 03FD4000005E80001h

_RDATA ENDS


.code
double_rsqrt_52 PROC public

	sub rsp, 40
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7


	vmovupd zmm4, [rcx]		; vbroadcastsd zmm4, big_num
	vmovapd zmm0, one		; vmovapd zmm0, One
	vmovapd zmm5, dc1		; vmovapd zmm5, dc1
	vmovapd zmm6, dc2		; vmovapd zmm6, dc2
	vmovapd zmm7, dc3		; vmovapd zmm7, dc3

	vrsqrt14pd zmm3, zmm4
	vfpclasspd k1, zmm4, 05eh	; vfpclasspd k1, zmm4, 5eh
	vmulpd zmm1, zmm3, zmm4 {rn-sae}
	vfnmadd231pd zmm0, zmm3, zmm1
	vfmsub231pd zmm1, zmm3, zmm4 {rn-sae}
	vfnmadd213pd zmm1, zmm3, zmm0
	vmovups zmm0, zmm7
	vmulpd zmm2, zmm3, zmm1
	vfmadd213pd zmm0, zmm1, zmm6
	vfmadd213pd zmm0, zmm1, zmm5
	vfmadd213pd zmm0, zmm2, zmm3
	vorpd zmm0{k1}, zmm3, zmm3

	vmovups [rdx], zmm0

	vzeroupper
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 40
	ret

double_rsqrt_52 ENDP
end
