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

;	.globl avx2_gatherpd

	; void avx2_gatherpd(size_t len, uint32_t* index_buffer, double* imaginary_buffer,
	;                    double* real_buffer, complex_num* complex_buffer);
	; On entry:
	;     rcx = len (length in elements of )
	;     rdx = index_buffer
	;     r8 = imaginary_buffer
	;     r9 = real_buffer
	;     [rsp+40]  = complex_buffer


.code
avx2_gatherpd PROC public
	sub rsp, 152
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10
	vmovaps xmmword ptr[rsp+80], xmm11
	vmovaps xmmword ptr[rsp+96], xmm12
	vmovaps xmmword ptr[rsp+112], xmm13
	vmovaps xmmword ptr[rsp+128], xmm14

	mov r10, qword ptr[rsp+40+152]
	mov eax, 80000000h
	movd xmm0, eax
	mov eax, 1
	movd xmm13, eax
	vpbroadcastd ymm13, xmm13
	vpbroadcastd ymm0, xmm0
	mov rax, r8
	mov r11, rcx
	xor r8, r8

loop_start:
	vmovdqu ymm1, ymmword ptr [rdx+r8*4]
	vpaddd ymm3, ymm1, ymm1
	vpaddd ymm14, ymm13, ymm3
	vxorpd ymm5, ymm5, ymm5
	vmovdqa ymm2, ymm0
	vxorpd ymm6, ymm6, ymm6
	vmovdqa ymm4, ymm0
	vxorpd ymm10, ymm10, ymm10
	vmovdqa ymm7, ymm0
	vxorpd ymm11, ymm11, ymm11
	vmovdqa ymm9, ymm0
	vextracti128 xmm12, ymm14, 1
	vextracti128 xmm8, ymm3, 1
	vgatherdpd ymm6, [r10+xmm8*8], ymm4
	vgatherdpd ymm5, [r10+xmm3*8], ymm2
	vmovupd ymmword ptr [r9+r8*8], ymm5
	vmovupd ymmword ptr [r9+r8*8+20h], ymm6
	vgatherdpd ymm11, [r10+xmm12*8], ymm7
	vgatherdpd ymm10, [r10+xmm14*8], ymm9
	vmovupd ymmword ptr [rax+r8*8], ymm10
	vmovupd ymmword ptr [rax+r8*8+20h], ymm11
	add r8, 8
	cmp r8, r11
	jb loop_start

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
	add rsp, 152
	ret
avx2_gatherpd ENDP
end