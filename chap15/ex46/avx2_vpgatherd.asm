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

;	.globl avx2_vpgatherd

	; void avx2_vpgatherd(size_t len, complex_num* complex_buffer, float* imaginary_buffer,
	;              	      float* real_buffer);
	; On entry:
	;     rcx = len (length in elements of )
	;     rdx = complex_buffer
	;     r8 = imaginary_buffer
	;     r9 = real_buffer


_RDATA SEGMENT    READ ALIGN(32) 'DATA'

real_offset   DQ 200000000h
              DQ 600000004h
              DQ 0A00000008h
              DQ 0D0000000Ch

cplx_offset   DQ 300000001h
              DQ 700000005h
              DQ 0B00000009h
              DQ 0F0000000Dh

_RDATA ENDS


.code
avx2_vpgatherd PROC public
	sub rsp, 24
	vmovaps xmmword ptr[rsp], xmm6
	mov eax, 80000000h
	movd xmm0, eax
	vpbroadcastd ymm0, xmm0
	vmovdqa ymm2, ymmword ptr real_offset
	vmovdqa ymm1, ymmword ptr cplx_offset
;	mov r9, rcx
;	mov r8, rdx
;	mov r10, rdx
	mov r10, rcx
	xor rcx, rcx

loop_start:
	lea r11, [rdx+rcx*8]
	vpxor ymm5, ymm5, ymm5
	add rcx, 8
	vpxor ymm6, ymm6, ymm6
	vmovdqa ymm3, ymm0
	vmovdqa ymm4, ymm0
	vpgatherdd ymm5, [r11+ymm2*4], ymm3
	vpgatherdd ymm6, [r11+ymm1*4], ymm4
	vmovdqu ymmword ptr [r9], ymm5
	vmovdqu ymmword ptr [r8], ymm6
	add r9, 20h
	add r8, 20h
	cmp rcx, r10
	jl loop_start

	vzeroupper
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 24
	ret
avx2_vpgatherd ENDP
end