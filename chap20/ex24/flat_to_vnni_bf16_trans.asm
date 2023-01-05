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

M EQU 64
N EQU 16
I_STRIDE EQU 32
O_STRIDE EQU 256

	;.intel_syntax noprefix

	;.globl _flat_to_vnni_bf16_trans
	;.globl flat_to_vnni_bf16_trans

	; void flat_to_vnni_bf16_trans(const bfloat_16 *input, bfloat_16 *output);
	; On entry:
	;     rcx = input
	;     rdx = output

	;.text

;
.code
flat_to_vnni_bf16_trans PROC public

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
	mov rdx, M / 16
L_M:
	vbroadcasti32x4 zmm0, xmmword ptr [r8]
	vbroadcasti32x4 zmm0{k1}, xmmword ptr [r8+I_STRIDE*4]
	vbroadcasti32x4 zmm0{k2}, xmmword ptr [r8+I_STRIDE*8]
	vbroadcasti32x4 zmm0{k3}, xmmword ptr [r8+I_STRIDE*12]
	vbroadcasti32x4 zmm1, xmmword ptr [r8+I_STRIDE*1]
	vbroadcasti32x4 zmm1{k1}, xmmword ptr [r8+I_STRIDE*5]
	vbroadcasti32x4 zmm1{k2}, xmmword ptr [r8+I_STRIDE*9]
	vbroadcasti32x4 zmm1{k3}, xmmword ptr [r8+I_STRIDE*13]
	vbroadcasti32x4 zmm2, xmmword ptr [r8+I_STRIDE*2]
	vbroadcasti32x4 zmm2{k1}, xmmword ptr [r8+I_STRIDE*6]
	vbroadcasti32x4 zmm2{k2}, xmmword ptr [r8+I_STRIDE*10]
	vbroadcasti32x4 zmm2{k3}, xmmword ptr [r8+I_STRIDE*14]
	vbroadcasti32x4 zmm3, xmmword ptr [r8+I_STRIDE*3]
	vbroadcasti32x4 zmm3{k1}, xmmword ptr [r8+I_STRIDE*7]
	vbroadcasti32x4 zmm3{k2}, xmmword ptr [r8+ I_STRIDE*11]
	vbroadcasti32x4 zmm3{k3}, xmmword ptr [r8+ I_STRIDE*15]

	vpunpckldq zmm4, zmm0, zmm1
	vpunpckhdq zmm5, zmm0, zmm1
	vpunpckldq zmm6, zmm2, zmm3
	vpunpckhdq zmm7, zmm2, zmm3
	vpunpcklqdq zmm0, zmm4, zmm6
	vpunpckhqdq zmm1, zmm4, zmm6
	vpunpcklqdq zmm2, zmm5, zmm7
	vpunpckhqdq zmm3, zmm5, zmm7

	vmovups zmmword ptr [r9], zmm0
	vmovups zmmword ptr [r9+O_STRIDE], zmm1
	vmovups zmmword ptr [r9+O_STRIDE*2], zmm2
	vmovups zmmword ptr [r9+O_STRIDE*3], zmm3

	add r9, 040h
	add r8, I_STRIDE*16
	dec rdx
	jnz L_M
	add r9, (O_STRIDE*4) - ((M/16)*040h)
	sub r8, (I_STRIDE*M-010h)
	dec rax
	jnz L_N

	vzeroupper
	ret

flat_to_vnni_bf16_trans ENDP
end
