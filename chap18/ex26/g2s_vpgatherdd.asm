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


;	.globl g2s_vpgatherdd

	; void g2s_vpgatherdd(uint32_t len, complex_num *complex_buffer,
	;	              float *imaginary_buffer, float *real_buffer);
	;     ecx = len
	;     rdx = complex_buffer
	;     r8 = imaginary_buffer
	;     r9 = real_buffer


_RDATA SEGMENT    READ ALIGN(64) 'DATA'

gather_imag_index DD 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31
gather_real_index DD 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30

_RDATA ENDS


.code
g2s_vpgatherdd PROC public

	vmovaps zmm0, gather_imag_index
	vmovaps zmm1, gather_real_index

	push r14

	mov r11, rdx
	mov r14d, ecx
	shr r14d, 5
	mov r10, r8
	xor r8d, r8d
	xor edx, edx

loop1:
	vpcmpeqb k1, xmm0, xmm0
	vpcmpeqb k2, xmm0, xmm0
	movsxd r8, r8d
	movsxd rcx, edx
	inc edx
	shl rcx, 07h
	vpxord zmm2, zmm2, zmm2
	lea rax, [r11+r8*8]
	add r8d, 020h
	vpgatherdd zmm2{k1}, [rax+zmm1*4]
	vpxord zmm3, zmm3, zmm3
	vpxord zmm4, zmm4, zmm4
	vpxord zmm5, zmm5, zmm5
	vpgatherdd zmm3{k2}, [rax+zmm0*4]
	vpcmpeqb k3, xmm0, xmm0
	vpcmpeqb k4, xmm0, xmm0
	vmovups [r9+rcx*1], zmm2
	vmovups [r10+rcx*1], zmm3
	vpgatherdd zmm4{k3}, [rax+zmm1*4+080h]
	vpgatherdd zmm5{k4}, [rax+zmm0*4+080h]
	vmovups [r9+rcx*1+040h], zmm4
	vmovups [r10+rcx*1+040h], zmm5
	cmp edx, r14d
	jb loop1

	vzeroupper

	pop r14

	ret
g2s_vpgatherdd ENDP
end