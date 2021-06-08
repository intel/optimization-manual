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


;	.globl ternary_avx512

	; void ternary_avx512(uint32_t *dest, const uint32_t *src1, const uint32_t *src2, const uint32_t *src3, uint64_t len)
	; On entry:
	;     rcx = dest
	;     rdx = src1
	;     r8 = src2
	;     r9 = src3
	;     [rsp+40] = len  ( must be divisible by 32 )


.code
ternary_avx512 PROC public
	mov rax,[rsp+40]
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
	vmovups zmm2, zmmword ptr [rdx+r10*4]
	vmovups zmm4, zmmword ptr [rdx+r10*4+40h]
	vmovups zmm6, zmmword ptr [r8+r10*4]
	vmovups zmm8, zmmword ptr [r8+r10*4+40h]
	vmovups zmm3, zmmword ptr [r9+r10*4]
	vmovups zmm5, zmmword ptr [r9+r10*4+40h]
	vpandd zmm0, zmm2, zmm6
	vpandd zmm1, zmm4, zmm8
	vpxord zmm7, zmm2, zmm3
	vpxord zmm9, zmm4, zmm5
	vpandd zmm10, zmm0, zmm3
	vpandd zmm12, zmm1, zmm5
	vpandnd zmm11, zmm6, zmm7
	vpandnd zmm13, zmm8, zmm9
	vpord zmm14, zmm10, zmm11
	vpord zmm15, zmm12, zmm13
	vmovups zmmword ptr [rcx+r10*4], zmm14
	vmovups zmmword ptr [rcx+r10*4+40h], zmm15
	add r10, 20h
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

ternary_avx512 ENDP
end