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

;	.globl vinsertps_transpose

	; void vinsertps_transpose(float *in[8], float *out[8], size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


.code
vinsertps_transpose PROC public
	sub rsp, 104
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10
	vmovaps xmmword ptr[rsp+80], xmm11

				   ; mov rcx, inpBuf
	mov r10, r8    ; mov r10, NumOfLoops
	mov r8, rdx    ; mov rdx, outBuf

loop1:
	vmovaps xmm0, [rcx]
	vinsertf128 ymm0, ymm0, [rcx + 128], 1
	vmovaps xmm1, [rcx + 32]
	vinsertf128 ymm1, ymm1, [rcx + 160], 1
	vunpcklpd ymm8, ymm0, ymm1
	vunpckhpd ymm9, ymm0, ymm1
	vmovaps xmm2, [rcx+64]
	vinsertf128 ymm2, ymm2, [rcx + 192], 1
	vmovaps	xmm3, [rcx+96]
	vinsertf128 ymm3, ymm3, [rcx + 224], 1
	vunpcklpd ymm10, ymm2, ymm3
	vunpckhpd ymm11, ymm2, ymm3
	vshufps	ymm4, ymm8, ymm10, 88h
	vmovaps	[r8], ymm4
	vshufps	ymm5, ymm8, ymm10, 0DDh
	vmovaps	[r8+32], ymm5
	vshufps	ymm6, ymm9, ymm11, 88h
	vmovaps	[r8+64], ymm6
	vshufps	ymm7, ymm9, ymm11, 0DDh
	vmovaps	[r8+96], ymm7
	vmovaps xmm0, [rcx+16]
	vinsertf128 ymm0, ymm0, [rcx + 144], 1
	vmovaps xmm1, [rcx + 48]
	vinsertf128 ymm1, ymm1, [rcx + 176], 1
	vunpcklpd ymm8, ymm0, ymm1
	vunpckhpd ymm9, ymm0, ymm1
	vmovaps xmm2, [rcx+80]
	vinsertf128 ymm2, ymm2, [rcx + 208], 1
	vmovaps xmm3, [rcx+112]
	vinsertf128 ymm3, ymm3, [rcx + 240], 1
	vunpcklpd ymm10, ymm2, ymm3
	vunpckhpd ymm11, ymm2, ymm3
	vshufps ymm4, ymm8, ymm10, 88h
	vmovaps [r8+128], ymm4
	vshufps ymm5, ymm8, ymm10, 0DDh
	vmovaps [r8+160], ymm5
	vshufps ymm6, ymm9, ymm11, 088h
	vmovaps [r8+192], ymm6
	vshufps ymm7, ymm9, ymm11, 0DDh
	vmovaps [r8+224], ymm7
	dec r10
	jnz loop1

	vzeroupper
	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm9, xmmword ptr[rsp+48]
	vmovaps xmm10, xmmword ptr[rsp+64]
	vmovaps xmm11, xmmword ptr[rsp+80]
	add rsp, 104
	ret
vinsertps_transpose ENDP
end