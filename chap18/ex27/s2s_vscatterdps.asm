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


;	.globl s2s_vscatterdps

	; void s2s_vscatterdps(uint64_t len, float *imaginary_buffer,
	;                      float *real_buffer, complex_num *complex_buffer);
	;     rcx = len
	;     rdx = imaginary_buffer
	;     r8 = real_buffer
	;     r9 = complex_buffer


_RDATA SEGMENT    READ ALIGN(64) 'DATA'

gather_imag_index DD 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31
gather_real_index DD 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30

_RDATA ENDS


.code
s2s_vscatterdps PROC public

	vmovaps zmm0, gather_imag_index
	vmovaps zmm1, gather_real_index

	mov rax, r9
	mov r10, rdx
	xor r9, r9
	xor rdx, rdx

loop1:
	vpcmpeqb k1, xmm0, xmm0
	lea r11, [rax+r9*4]
	vpcmpeqb k2, xmm0, xmm0
	vmovups zmm2, [r8+rdx*4]
	vmovups zmm3, [r10+rdx*4]
	vscatterdps [r11+zmm1*4]{k1}, zmm2
	vscatterdps [r11+zmm0*4]{k2}, zmm3
	add rdx, 010h
	add r9, 020h
	cmp rdx, rcx
	jl loop1

	vzeroupper

	ret
s2s_vscatterdps ENDP
end