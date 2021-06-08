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


;	.globl qword_avx512_ass

	; void qword_avx512_ass(const int64_t *a, const int64_t *b, int64_t *c, uint64_t count);
	;
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = c
	;     r9 = count


.code
qword_avx512_ass PROC public

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

	shr r9, 5
	xor rax, rax
	xor r10d, r10d

loop1:
	vmovups zmm0, zmmword ptr [rcx+rax*8]
	inc r10d
	vmovups zmm5, zmmword ptr [rcx+rax*8+40h]
	vmovups zmm10, zmmword ptr [rcx+rax*8+80h]
	vmovups zmm15, zmmword ptr [rcx+rax*8+0c0h]
	vmovups zmm1, zmmword ptr [rdx+rax*8]
	vmovups zmm6, zmmword ptr [rdx+rax*8+40h]
	vmovups zmm11, zmmword ptr [rdx+rax*8+80h]
	vmovups zmm16, zmmword ptr [rdx+rax*8+0c0h]
	vpaddq zmm2, zmm0, zmm1
	vpmullq zmm3, zmm0, zmm1
	vpaddq zmm7, zmm5, zmm6
	vpmullq zmm8, zmm5, zmm6
	vpaddq zmm12, zmm10, zmm11
	vpmullq zmm13, zmm10, zmm11
	vpaddq zmm17, zmm15, zmm16
	vpmullq zmm18, zmm15, zmm16
	vpmaxsq zmm4, zmm2, zmm3
	vpmaxsq zmm9, zmm7, zmm8
	vpmaxsq zmm14, zmm12, zmm13
	vpmaxsq zmm19, zmm17, zmm18
	vmovups zmmword ptr [r8], zmm4
	vmovups zmmword ptr [r8+40h], zmm9
	vmovups zmmword ptr [r8+80h], zmm14
	vmovups zmmword ptr [r8+0c0h], zmm19
	add rax, 20h
	add r8, 100h
	cmp r10d, r9d
	jb loop1

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
qword_avx512_ass ENDP
end
