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


;	.globl g2s_vpermi2d

	; void g2s_vpermi2d(uint32_t len, complex_num *complex_buffer,
	;	            float *imaginary_buffer, float *real_buffer);
	;     rcx = len
	;     rdx = complex_buffer
	;     r8 = imaginary_buffer
	;     r9 = real_buffer


_RDATA SEGMENT    READ ALIGN(64) 'DATA'

gather_imag_index DD 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31
gather_real_index DD 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30

_RDATA ENDS


.code
g2s_vpermi2d PROC public

	sub rsp, 40
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	
	vmovups zmm6, gather_imag_index
	vmovups zmm7, gather_real_index

	xor r10, r10

loop1:
	vmovups zmm4, [rdx+r10*8]
	vmovups zmm0, [rdx+r10*8+040h]
	vmovups zmm5, [rdx+r10*8+080h]
	vmovups zmm1, [rdx+r10*8+0c0h]
	vmovaps zmm2, zmm7
	vmovaps zmm3, zmm7
	vpermi2d zmm2, zmm4, zmm0
	vpermt2d zmm4, zmm6, zmm0
	vpermi2d zmm3, zmm5, zmm1
	vpermt2d zmm5, zmm6, zmm1
	vmovdqu32 [r9+r10*4], zmm2
	vmovdqu32 [r9+r10*4+040h], zmm3
	vmovdqu32 [r8+r10*4], zmm4
	vmovdqu32 [r8+r10*4+040h], zmm5
	add r10, 020h
	cmp r10, rcx
	jb loop1

	vzeroupper

	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 40

	ret
g2s_vpermi2d ENDP
end
