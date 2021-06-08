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


;	.globl s2s_vpermi2d

	; void s2s_vpermi2d(int64_t len, float *imaginary_buffer,
	;                   float *real_buffer, complex_num *complex_buffer);
	;     rcx = len
	;     rdx = imaginary_buffer
	;     r8 = real_buffer
	;     r9 = complex_buffer

_RDATA SEGMENT    READ ALIGN(64) 'DATA'

first_half  DD 0, 16, 1, 17, 2, 18, 3, 19, 4, 20, 5, 21, 6, 22, 7, 23
second_half DD 8, 24, 9, 25, 10, 26, 11, 27, 12, 28, 13, 29, 14, 30, 15, 31

_RDATA ENDS



.code
s2s_vpermi2d PROC public

	vmovups zmm1, first_half
	vmovups zmm0, second_half

	mov rax, r8
	mov r10, rdx
	xor rdx, rdx
	xor r8, r8

loop1:
	vmovups zmm4, [rax+r8*4]
	vmovups zmm2, [r10+r8*4]
	vmovaps zmm3, zmm1
	add r8, 010h
	vpermi2d zmm3, zmm4, zmm2
	vpermt2d zmm4, zmm0, zmm2
	vmovups [r9+rdx*4], zmm3
	vmovups [r9+rdx*4+040h], zmm4
	add rdx, 020h
	cmp r8, rcx
	jl loop1

	vzeroupper

	ret

s2s_vpermi2d ENDP
end