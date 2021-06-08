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

;	.globl vshufps_transpose

	; void vshufps_transpose(float *in[8], float *out[8], size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


.code
vshufps_transpose PROC public
	sub rsp, 168
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10
	vmovaps xmmword ptr[rsp+80], xmm11
	vmovaps xmmword ptr[rsp+96], xmm12
	vmovaps xmmword ptr[rsp+112], xmm13
	vmovaps xmmword ptr[rsp+128], xmm14
	vmovaps xmmword ptr[rsp+144], xmm15

				   ; movrcx, inpBuf
	mov r10, r8    ; movr10, NumOfLoops
	mov r8, rdx    ; movrdx, outBuf

loop1:
	vmovaps ymm9, [rcx]
	vmovaps ymm10, [rcx+32]
	vmovaps ymm11, [rcx+64]
	vmovaps ymm12, [rcx+96]
	vmovaps ymm13, [rcx+128]
	vmovaps ymm14, [rcx+160]
	vmovaps ymm15, [rcx+192]
	vmovaps ymm2, [rcx+224]
	vunpcklps ymm6, ymm9, ymm10
	vunpcklps ymm1, ymm11, ymm12
	vunpckhps ymm8, ymm9, ymm10
	vunpcklps ymm0, ymm13, ymm14
	vunpcklps ymm9, ymm15, ymm2
	vshufps ymm3, ymm6, ymm1, 4Eh
	vshufps ymm10, ymm6, ymm3, 0E4h
	vshufps ymm6, ymm0, ymm9, 4Eh
	vunpckhps ymm7, ymm11, ymm12
	vshufps ymm11, ymm0, ymm6, 0E4h
	vshufps ymm12, ymm3, ymm1, 0E4h
	vperm2f128 ymm3, ymm10, ymm11, 20h
	vmovaps [r8], ymm3
	vunpckhps ymm5, ymm13, ymm14
	vshufps ymm13, ymm6, ymm9, 0E4h
	vunpckhps ymm4, ymm15, ymm2
	vperm2f128 ymm2, ymm12, ymm13, 20h
	vmovaps 32[r8], ymm2
	vshufps ymm14, ymm8, ymm7, 4Eh
	vshufps ymm15, ymm14, ymm7, 0E4h
	vshufps ymm7, ymm5, ymm4, 4Eh
	vshufps ymm8, ymm8, ymm14, 0E4h
	vshufps ymm5, ymm5, ymm7, 0E4h
	vperm2f128 ymm6, ymm8, ymm5, 20h
	vmovaps 64[r8], ymm6
	vshufps ymm4, ymm7, ymm4, 0E4h
	vperm2f128 ymm7, ymm15, ymm4, 20h
	vmovaps 96[r8], ymm7
	vperm2f128 ymm1, ymm10, ymm11, 31h
	vperm2f128 ymm0, ymm12, ymm13, 31h
	vmovaps 128[r8], ymm1
	vperm2f128 ymm5, ymm8, ymm5, 31h
	vperm2f128 ymm4, ymm15, ymm4, 31h
	vmovaps  160[r8], ymm0
	vmovaps  192[r8], ymm5
	vmovaps  224[r8], ymm4
	dec r10
	jnz loop1

	vzeroupper
	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm9, xmmword ptr[rsp+48]
	vmovaps xmm10, xmmword ptr[rsp+64]
	vmovaps xmm11, xmmword ptr[rsp+80]
	vmovaps xmm12, xmmword ptr[rsp+96]
	vmovaps xmm13, xmmword ptr[rsp+112]
	vmovaps xmm14, xmmword ptr[rsp+128]
	vmovaps xmm15, xmmword ptr[rsp+144]
	add rsp, 168
	ret
vshufps_transpose ENDP
end