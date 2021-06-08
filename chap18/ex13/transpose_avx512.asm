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

;	.globl transpose_avx512

	; void transpose_avx512(uint16_t *out, const uint16_t *in)
	; On entry:
	;     rcx = out
	;     rdx = in


_RDATA SEGMENT    READ ALIGN(64) 'DATA'

permMaskBuffer DW 0, 8, 16, 24, 32, 40, 48, 56
DW 1, 9, 17, 25, 33, 41, 49, 57
DW 2, 10, 18, 26, 34, 42, 50, 58
DW 3, 11, 19, 27, 35, 43, 51, 59
DW 4, 12, 20, 28, 36, 44, 52, 60
DW 5, 13, 21, 29, 37, 45, 53, 61
DW 6, 14, 22, 30, 38, 46, 54, 62
DW 7, 15, 23, 31, 39, 47, 55, 63

_RDATA ENDS

.code
transpose_avx512 PROC public
	lea rax, permMaskBuffer		; mov rax, permMaskBuffer
	vmovdqa32 zmm4, [rax]
	vmovdqa32 zmm5, [rax+40h]
					; mov rdx, pImage
					; mov rcx, pOutImage
	xor r8, r8
matrix_loop:
	vmovdqa32 zmm2, [rdx]
	vmovdqa32 zmm3, [rdx+40h]
	vmovdqa32 zmm0, zmm4
	vmovdqa32 zmm1, zmm5
	vpermi2w zmm0, zmm2, zmm3
	vpermi2w zmm1, zmm2, zmm3
	vmovdqa32 [rcx], zmm0
	vmovdqa32 [rcx+40h], zmm1
	add r8, 1
	add rdx, 64*2
	add rcx, 64*2
	cmp r8, 50
	jne matrix_loop

	vzeroupper
	ret
transpose_avx512 ENDP
end

