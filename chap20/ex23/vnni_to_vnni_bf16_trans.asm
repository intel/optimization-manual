;
; Copyright (C) 2022 by Intel Corporation
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

; M and N here are for the matrix in VNNI format

M        EQU 16
N        EQU 16
ON       EQU 64
I_STRIDE EQU N*2
O_STRIDE EQU 128

	;.intel_syntax noprefix

	;.globl _vnni_to_vnni_bf16_trans
	;.globl vnni_to_vnni_bf16_trans

	; void vnni_to_vnni_bf16_trans(const bfloat_16 *input, bfloat_16 *output);
	; On entry:
	;     rcx = input
	;     rdx = output

	;.text

;

_RDATA SEGMENT    READ ALIGN(16) 'DATA'
shuflle_cntrl DD  05040100h, 07060302h, 0d0c0908h, 0f0e0b0ah
_RDATA ENDS


.code
vnni_to_vnni_bf16_trans PROC public

	mov r8, rcx
	mov r9, rdx
	vbroadcasti32x4 zmm31, xmmword ptr shuflle_cntrl
	mov r10, 0f0h
	kmovd k1, r10d
	mov r10, 0f00h
	kmovd k2, r10d
	mov r10, 0f000h
	kmovd k3, r10d
	mov rax, N / 8
L_N:
	mov rdx, M / 8
L_M:

	vbroadcasti32x4 zmm0, xmmword ptr [r8]
	vbroadcasti32x4 zmm0{k1}, xmmword ptr [r8+I_STRIDE*2]
	vbroadcasti32x4 zmm0{k2}, xmmword ptr [r8+I_STRIDE*4]
	vbroadcasti32x4 zmm0{k3}, xmmword ptr [r8+I_STRIDE*6]
	vbroadcasti32x4 zmm1, xmmword ptr [r8+I_STRIDE*1]
	vbroadcasti32x4 zmm1{k1}, xmmword ptr [r8+I_STRIDE*3]
	vbroadcasti32x4 zmm1{k2}, xmmword ptr [r8+I_STRIDE*5]
	vbroadcasti32x4 zmm1{k3}, xmmword ptr [r8+I_STRIDE*7]

	vpshufb zmm2, zmm0, zmm31
	vpshufb zmm3, zmm1, zmm31
	vpunpcklqdq zmm0, zmm2, zmm3
	vpunpckhqdq zmm1, zmm2, zmm3

	vmovdqu16 zmmword ptr [r9], zmm0
	vmovdqu16 zmmword ptr [r9+O_STRIDE], zmm1

	add r9, 040h
	add r8, I_STRIDE*8
	dec rdx
	jnz L_M

	add r9, (O_STRIDE*2) - ((M/8) * 040h)
	sub r8, (I_STRIDE*M-010h)
	dec rax
	jnz L_N

	vzeroupper
	ret

vnni_to_vnni_bf16_trans ENDP
end
