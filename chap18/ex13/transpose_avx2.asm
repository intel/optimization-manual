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

;	.globl transpose_avx2

	; void transpose_avx2(uint16_t *out, const uint16_t *in)
	; On entry:
	;     rcx = out
	;     rdx = in


.code
transpose_avx2 PROC public

					; mov rdx, pImage
					; mov rcx, pOutImage
	sub rsp, 40
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	xor r8, r8
matrix_loop:
	vmovdqa xmm0, xmmword ptr[rdx]
	vmovdqa xmm1, xmmword ptr[rdx+10h]
	vmovdqa xmm2, xmmword ptr[rdx+20h]
	vmovdqa xmm3, xmmword ptr[rdx+30h]
	vinserti128 ymm0, ymm0, xmmword ptr[rdx+40h], 1
	vinserti128 ymm1, ymm1, xmmword ptr[rdx+50h], 1
	vinserti128 ymm2, ymm2, xmmword ptr[rdx+60h], 1
	vinserti128 ymm3, ymm3, xmmword ptr[rdx+70h], 1
	vpunpcklwd ymm4, ymm0, ymm1
	vpunpckhwd ymm5, ymm0, ymm1
	vpunpcklwd ymm6, ymm2, ymm3
	vpunpckhwd ymm7, ymm2, ymm3
	vpunpckldq ymm0, ymm4, ymm6
	vpunpckhdq ymm1, ymm4, ymm6
	vpunpckldq ymm2, ymm5, ymm7
	vpunpckhdq ymm3, ymm5, ymm7
	vpermq ymm0, ymm0, 0D8h
	vpermq ymm1, ymm1, 0D8h
	vpermq ymm2, ymm2, 0D8h
	vpermq ymm3, ymm3, 0D8h
	vmovdqa ymmword ptr[rcx], ymm0
	vmovdqa ymmword ptr[rcx+20h], ymm1
	vmovdqa ymmword ptr[rcx+40h], ymm2
	vmovdqa ymmword ptr[rcx+60h], ymm3
	add r8, 1
	add rdx, 64*2
	add rcx, 64*2
	cmp r8, 50
	jne matrix_loop

	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	add rsp, 40

	vzeroupper
	ret
transpose_avx2 ENDP
end