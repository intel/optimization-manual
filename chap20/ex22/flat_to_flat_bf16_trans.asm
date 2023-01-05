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

M        EQU 64
N        EQU 16
I_STRIDE EQU 32
O_STRIDE EQU 128

	;.intel_syntax noprefix

	;.globl _flat_to_flat_bf16_trans
	;.globl flat_to_flat_bf16_trans

	; void flat_to_flat_bf16_trans(const bfloat_16 *input, bfloat_16 *output);
	; On entry:
	;     rcx = input
	;     rdx = output

	;.text

;
.code
flat_to_flat_bf16_trans PROC public

	mov r8, rcx
	mov r9, rdx

	mov r10, 0f0h
	kmovd k1, r10d
	mov r10, 0f00h
	kmovd k2, r10d
	mov r10, 0f000h
	kmovd k3, r10d
	mov rax, N / 8

L_N:
	mov rdx, M / 32
L_M:
	vbroadcasti32x4 zmm0, xmmword ptr [r8]
	vbroadcasti32x4 zmm0{k1}, xmmword ptr [r8+I_STRIDE*8]
	vbroadcasti32x4 zmm0{k2}, xmmword ptr [r8+I_STRIDE*16]
	vbroadcasti32x4 zmm0{k3}, xmmword ptr [r8+I_STRIDE*24]
	vbroadcasti32x4 zmm1, xmmword ptr [r8+I_STRIDE*1]
	vbroadcasti32x4 zmm1{k1}, xmmword ptr [r8+I_STRIDE*9]
	vbroadcasti32x4 zmm1{k2}, xmmword ptr [r8+I_STRIDE*17]
	vbroadcasti32x4 zmm1{k3}, xmmword ptr [r8+I_STRIDE*25]
	vbroadcasti32x4 zmm2, xmmword ptr [r8+I_STRIDE*2]
	vbroadcasti32x4 zmm2{k1}, xmmword ptr [r8+I_STRIDE*10]
	vbroadcasti32x4 zmm2{k2}, xmmword ptr [r8+I_STRIDE*18]
	vbroadcasti32x4 zmm2{k3}, xmmword ptr [r8+I_STRIDE*26]
	vbroadcasti32x4 zmm3, xmmword ptr [r8+I_STRIDE*3]
	vbroadcasti32x4 zmm3{k1}, xmmword ptr [r8+I_STRIDE*11]
	vbroadcasti32x4 zmm3{k2}, xmmword ptr [r8+I_STRIDE*19]
	vbroadcasti32x4 zmm3{k3}, xmmword ptr [r8+I_STRIDE*27]
	vbroadcasti32x4 zmm4, xmmword ptr [r8+I_STRIDE*4]
	vbroadcasti32x4 zmm4{k1}, xmmword ptr [r8+I_STRIDE*12]
	vbroadcasti32x4 zmm4{k2}, xmmword ptr [r8+I_STRIDE*20]
	vbroadcasti32x4 zmm4{k3}, xmmword ptr [r8+I_STRIDE*28]
	vbroadcasti32x4 zmm5, xmmword ptr [r8+I_STRIDE*5]
	vbroadcasti32x4 zmm5{k1}, xmmword ptr [r8+I_STRIDE*13]
	vbroadcasti32x4 zmm5{k2}, xmmword ptr [r8+I_STRIDE*21]
	vbroadcasti32x4 zmm5{k3}, xmmword ptr [r8+I_STRIDE*29]
	vbroadcasti32x4 zmm6, xmmword ptr [r8+I_STRIDE*6]
	vbroadcasti32x4 zmm6{k1}, xmmword ptr [r8+I_STRIDE*14]
	vbroadcasti32x4 zmm6{k2}, xmmword ptr [r8+I_STRIDE*22]
	vbroadcasti32x4 zmm6{k3}, xmmword ptr [r8+I_STRIDE*30]
	vbroadcasti32x4 zmm7, xmmword ptr [r8+I_STRIDE*7]
	vbroadcasti32x4 zmm7{k1}, xmmword ptr [r8+I_STRIDE*15]
	vbroadcasti32x4 zmm7{k2}, xmmword ptr [r8+I_STRIDE*23]
	vbroadcasti32x4 zmm7{k3}, xmmword ptr [r8+I_STRIDE*31]

	vpunpcklwd zmm8, zmm0, zmm1
	vpunpckhwd zmm9, zmm0, zmm1
	vpunpcklwd zmm10, zmm2, zmm3
	vpunpckhwd zmm11, zmm2, zmm3
	vpunpcklwd zmm12, zmm4, zmm5
	vpunpckhwd zmm13, zmm4, zmm5
	vpunpcklwd zmm14, zmm6, zmm7
	vpunpckhwd zmm15, zmm6, zmm7
	vpunpckldq zmm0, zmm8, zmm10
	vpunpckhdq zmm1, zmm8, zmm10
	vpunpckldq zmm2, zmm9, zmm11
	vpunpckhdq zmm3, zmm9, zmm11
	vpunpckldq zmm4, zmm12, zmm14
	vpunpckhdq zmm5, zmm12, zmm14
	vpunpckldq zmm6, zmm13, zmm15
	vpunpckhdq zmm7, zmm13, zmm15
	vpunpcklqdq zmm8, zmm0, zmm4
	vpunpckhqdq zmm9, zmm0, zmm4
	vpunpcklqdq zmm10, zmm1, zmm5
	vpunpckhqdq zmm11, zmm1, zmm5
	vpunpcklqdq zmm12, zmm2, zmm6
	vpunpckhqdq zmm13, zmm2, zmm6
	vpunpcklqdq zmm14, zmm3, zmm7
	vpunpckhqdq zmm15, zmm3, zmm7

	vmovdqu16 zmmword ptr [r9], zmm8
	vmovdqu16 zmmword ptr [r9+O_STRIDE], zmm9
	vmovdqu16 zmmword ptr [r9+O_STRIDE*2], zmm10
	vmovdqu16 zmmword ptr [r9+O_STRIDE*3], zmm11
	vmovdqu16 zmmword ptr [r9+O_STRIDE*4], zmm12
	vmovdqu16 zmmword ptr [r9+O_STRIDE*5], zmm13
	vmovdqu16 zmmword ptr [r9+O_STRIDE*6], zmm14
	vmovdqu16 zmmword ptr [r9+O_STRIDE*7], zmm15

	add r9, 64
	add r8, I_STRIDE*32
	dec rdx
	jnz L_M

	add r9, (O_STRIDE*8) - ((M/32) * 40h)
	sub r8, (I_STRIDE*M-10h)
	dec rax
	jnz L_N

	vzeroupper
	ret

flat_to_flat_bf16_trans ENDP
end
