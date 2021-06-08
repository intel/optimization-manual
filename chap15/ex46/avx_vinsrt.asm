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

;	.globl avx_vinsrt

	; void avx_vinsrt(size_t len, complex_num* complex_buffer, float* imaginary_buffer,
	;              	  float* real_buffer);
	; On entry:
	;     rcx = len (length in elements of )
	;     rdx = complex_buffer
	;     r8 = imaginary_buffer
	;     r9 = real_buffer


.code
avx_vinsrt PROC public
	sub rsp, 40
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
;	mov r9, rcx
;	mov r8, rdx
;	mov r10, rdx
	mov r10, rcx
	xor rcx, rcx

loop_start:
	vmovdqu xmm0, xmmword ptr [rdx+rcx*8]
	vmovdqu xmm1, xmmword ptr [rdx+rcx*8+10h]
	vmovdqu xmm4, xmmword ptr [rdx+rcx*8+40h]
	vmovdqu xmm5, xmmword ptr [rdx+rcx*8+50h]
	vinserti128 ymm2, ymm0, xmmword ptr [rdx+rcx*8+20h], 1
	vinserti128 ymm3, ymm1, xmmword ptr [rdx+rcx*8+30h], 1
	vinserti128 ymm6, ymm4, xmmword ptr [rdx+rcx*8+60h], 1
	vinserti128 ymm7, ymm5, xmmword ptr [rdx+rcx*8+70h], 1
	add rcx, 10h
	vshufps ymm0, ymm2, ymm3, 88h
	vshufps ymm1, ymm2, ymm3, 0ddh
	vshufps ymm4, ymm6, ymm7, 88h
	vshufps ymm5, ymm6, ymm7, 0ddh
	vmovups ymmword ptr [r9], ymm0
	vmovups ymmword ptr [r8], ymm1
	vmovups ymmword ptr [r9+20h], ymm4
	vmovups ymmword ptr [r8+20h], ymm5
	add r9, 40h
	add r8, 40h
	cmp rcx, r10
	jl loop_start

	vzeroupper
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 40
	ret
avx_vinsrt ENDP
end