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


;	.globl qword_avx2_ass

	; void qword_avx2_ass(const int64_t *a, const int64_t *b, int64_t *c, uint64_t count);
	;
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = c
	;     r9 = count


.code
qword_avx2_ass PROC public

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
	vmovdqu32 ymm28, ymmword ptr [rcx+rax*8+20h]
	inc r10d
	vmovdqu32 ymm26, ymmword ptr [rdx+rax*8+20h]
	vmovdqu32 ymm17, ymmword ptr [rdx+rax*8]
	vmovdqu32 ymm19, ymmword ptr [rcx+rax*8]
	vmovdqu ymm13, ymmword ptr [rcx+rax*8+40h]
	vmovdqu ymm11, ymmword ptr [rdx+rax*8+40h]
	vpsrlq ymm25, ymm28, 20h
	vpsrlq ymm27, ymm26, 20h
	vpsrlq ymm16, ymm19, 20h
	vpsrlq ymm18, ymm17, 20h
	vpaddq ymm6, ymm28, ymm26
	vpsrlq ymm10, ymm13, 20h
	vpsrlq ymm12, ymm11, 20h
	vpaddq ymm0, ymm19, ymm17
	vpmuludq ymm29, ymm25, ymm26
	vpmuludq ymm30, ymm27, ymm28
	vpaddd ymm31, ymm29, ymm30
	vmovdqu32 ymm29, ymmword ptr [rdx+rax*8+80h]
	vpsllq ymm5, ymm31, 20h
	vmovdqu32 ymm31, ymmword ptr [rcx+rax*8+80h]
	vpsrlq ymm30, ymm29, 20h
	vpmuludq ymm20, ymm16, ymm17
	vpmuludq ymm21, ymm18, ymm19
	vpmuludq ymm4, ymm28, ymm26
	vpaddd ymm22, ymm20, ymm21
	vpaddq ymm7, ymm4, ymm5
	vpsrlq ymm28, ymm31, 20h
	vmovdqu32 ymm20, ymmword ptr [rdx+rax*8+60h]
	vpsllq ymm24, ymm22, 20h
	vmovdqu32 ymm22, ymmword ptr [rcx+rax*8+60h]
	vpsrlq ymm21, ymm20, 20h
	vpaddq ymm4, ymm22, ymm20
	vpcmpgtq ymm8, ymm7, ymm6
	vblendvpd ymm9, ymm6, ymm7, ymm8
	vmovups ymmword ptr [r8+20h], ymm9
	vpmuludq ymm14, ymm10, ymm11
	vpmuludq ymm15, ymm12, ymm13
	vpmuludq ymm8, ymm28, ymm29
	vpmuludq ymm9, ymm30, ymm31
	vpmuludq ymm23, ymm19, ymm17
	vpaddd ymm16, ymm14, ymm15
	vpsrlq ymm19, ymm22, 20h
	vpaddd ymm10, ymm8, ymm9
	vpaddq ymm1, ymm23, ymm24
	vpsllq ymm18, ymm16, 20h
	vmovdqu32 ymm28, ymmword ptr [rcx+rax*8+0c0h]
	vpsllq ymm12, ymm10, 20h
	vpmuludq ymm23, ymm19, ymm20
	vpmuludq ymm24, ymm21, ymm22
	vpaddd ymm25, ymm23, ymm24
	vmovdqu32 ymm19, ymmword ptr [rcx+rax*8+0a0h]
	vpsllq ymm27, ymm25, 20h
	vpsrlq ymm25, ymm28, 20h
	vpsrlq ymm16, ymm19, 20h
	vpcmpgtq ymm2, ymm1, ymm0
	vblendvpd ymm3, ymm0, ymm1, ymm2
	vpaddq ymm0, ymm13, ymm11
	vmovups ymmword ptr [r8], ymm3
	vpmuludq ymm17, ymm13, ymm11
	vpmuludq ymm11, ymm31, ymm29
	vpaddq ymm1, ymm17, ymm18
	vpaddq ymm13, ymm31, ymm29
	vpaddq ymm14, ymm11, ymm12
	vmovdqu32 ymm17, ymmword ptr [rdx+rax*8+0a0h]
	vmovdqu ymm12, ymmword ptr [rdx+rax*8+0e0h]
	vpsrlq ymm18, ymm17, 20h
	vpcmpgtq ymm2, ymm1, ymm0
	vpmuludq ymm26, ymm22, ymm20
	vpcmpgtq ymm15, ymm14, ymm13
	vblendvpd ymm3, ymm0, ymm1, ymm2
	vblendvpd ymm0, ymm13, ymm14, ymm15
	vmovdqu ymm14, ymmword ptr [rcx+rax*8+0e0h]
	vmovups ymmword ptr [r8+40h], ymm3
	vmovups ymmword ptr [r8+80h], ymm0
	vpaddq ymm5, ymm26, ymm27
	vpsrlq ymm11, ymm14, 20h
	vpsrlq ymm13, ymm12, 20h
	vpaddq ymm1, ymm19, ymm17
	vpaddq ymm0, ymm14, ymm12
	vmovdqu32 ymm26, ymmword ptr [rdx+rax*8+0c0h]
	vpmuludq ymm20, ymm16, ymm17
	add rax, 20h
	vpmuludq ymm21, ymm18, ymm19
	vpaddd ymm22, ymm20, ymm21
	vpsrlq ymm27, ymm26, 20h
	vpsllq ymm24, ymm22, 20h
	vpmuludq ymm29, ymm25, ymm26
	vpmuludq ymm30, ymm27, ymm28
	vpmuludq ymm15, ymm11, ymm12
	vpmuludq ymm16, ymm13, ymm14
	vpmuludq ymm23, ymm19, ymm17
	vpaddd ymm31, ymm29, ymm30
	vpaddd ymm17, ymm15, ymm16
	vpaddq ymm2, ymm23, ymm24
	vpsllq ymm19, ymm17, 20h
	vpcmpgtq ymm6, ymm5, ymm4
	vblendvpd ymm7, ymm4, ymm5, ymm6
	vpsllq ymm6, ymm31, 20h
	vmovups ymmword ptr [r8+60h], ymm7
	vpaddq ymm7, ymm28, ymm26
	vpcmpgtq ymm3, ymm2, ymm1
	vpmuludq ymm5, ymm28, ymm26
	vpmuludq ymm18, ymm14, ymm12
	vblendvpd ymm4, ymm1, ymm2, ymm3
	vpaddq ymm8, ymm5, ymm6
	vpaddq ymm1, ymm18, ymm19
	vmovups ymmword ptr [r8+0a0h], ymm4
	vpcmpgtq ymm9, ymm8, ymm7
	vpcmpgtq ymm2, ymm1, ymm0
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vblendvpd ymm3, ymm0, ymm1, ymm2
	vmovups ymmword ptr [r8+0c0h], ymm10
	vmovups ymmword ptr [r8+0e0h], ymm3
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
qword_avx2_ass ENDP
end
