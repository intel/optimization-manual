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


;	.globl adj_vpgatherpd

	; void adj_vpgatherpd(int64_t len, const int32_t *indices,
	;                     const elem_struct_t *elems, double *out);
	;     rcx = len
	;     rdx = indices
	;     r8 = elems
	;     r9 = out

_RDATA SEGMENT    READ ALIGN(32) 'DATA'

index_inc DD 0, 8, 16, 24, 0, 8, 16, 24
index_scale DD 32, 32, 32, 32, 32, 32, 32, 32

_RDATA ENDS


.code
adj_vpgatherpd PROC public

	sub rsp, 24
	vmovaps xmmword ptr[rsp], xmm6

	vmovaps ymm0, index_inc
	vmovaps ymm1, index_scale
	mov eax, 0f0h
	kmovd k1, eax

	mov r10, rdx		; indices
	xor edx, edx

loop1:
	vpbroadcastd ymm3, DWORD PTR [r10+rdx*4]
	mov r11d, edx
	vpbroadcastd xmm2, DWORD PTR [r10+rdx*4+04h]
	add rdx, 02h
	vpbroadcastd ymm3{k1}, xmm2
	vpmulld ymm4, ymm3, ymm1
	vpaddd ymm5, ymm4, ymm0
	vpcmpeqb k2, xmm0, xmm0
	shl r11d, 02h
	movsxd r11, r11d
	vpxord zmm6, zmm6, zmm6
	vgatherdpd zmm6{k2}, [r8+ymm5*1]
	vmovups [r9+r11*8], zmm6
	cmp rdx, rcx
	jl loop1

	vzeroupper

	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 24

	ret

adj_vpgatherpd ENDP
end