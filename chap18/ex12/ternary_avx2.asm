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


;	.globl ternary_avx2

	; void ternary_avx2(uint32_t *dest, const uint32_t *src1, const uint32_t *src2, const uint32_t *src3, uint64_t len)
	; On entry:
	;     rcx = dest
	;     rdx = src1
	;     r8 = src2
	;     r9 = src3
	;     [rsp+40] = len  ( must be divisible by 16 )


.code
ternary_avx2 PROC public
	mov rax, [rsp+40]
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

	xor r10, r10

mainloop:
	vmovdqu ymm1, ymmword ptr [rdx+r10*4]
	vmovdqu ymm3, ymmword ptr [r8+r10*4]
	vmovdqu ymm2, ymmword ptr [r9+r10*4]
	vmovdqu ymm10, ymmword ptr [r9+r10*4+20h]
	vpand ymm0, ymm1, ymm3
	vpxor ymm4, ymm1, ymm2
	vpand ymm5, ymm0, ymm2
	vpandn ymm6, ymm3, ymm4
	vpor ymm7, ymm5, ymm6
	vmovdqu ymmword ptr [rcx+r10*4], ymm7
	vmovdqu ymm9, ymmword ptr [rdx+r10*4+20h]
	vmovdqu ymm11, ymmword ptr [r8+r10*4+20h]
	vpxor ymm12, ymm9, ymm10
	vpand ymm8, ymm9, ymm11
	vpandn ymm14, ymm11, ymm12
	vpand ymm13, ymm8, ymm10
	vpor ymm15, ymm13, ymm14
	vmovdqu ymmword ptr [rcx+r10*4+20h], ymm15
	add r10, 10h
	cmp r10, rax
	jb mainloop

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
ternary_avx2 ENDP
end