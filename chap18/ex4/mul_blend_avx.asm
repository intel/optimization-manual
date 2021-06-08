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

;	.globl mul_blend_avx

;	# void mul_blend_avx(double *a, double *b, double *c, size_t N);
;	# On entry:
;	#     rcx = a
;	#     rdx = b
;	#     r8 = c
;	#     r9 = N


.code
mul_blend_avx PROC public
	push rbx
	push r12
	sub rsp, 168
	vmovaps xmmword ptr [rsp], xmm6
	vmovaps xmmword ptr [rsp+16], xmm7
	vmovaps xmmword ptr [rsp+32], xmm8
	vmovaps xmmword ptr [rsp+48], xmm9
	vmovaps xmmword ptr [rsp+64], xmm10
	vmovaps xmmword ptr [rsp+80], xmm11
	vmovaps xmmword ptr [rsp+96], xmm12
	vmovaps xmmword ptr [rsp+112], xmm13
	vmovaps xmmword ptr [rsp+128], xmm14
	vmovaps xmmword ptr [rsp+144], xmm15


	mov rax, rcx       ; mov rax, a
	mov r11, rdx       ; mov r11, b
	mov r12, r9        ; mov r12, N
	shr r12, 5
	mov rdx, r8       ; mov rdx, c

	xor r9, r9
	xor r10, r10

loop1:
	vmovupd ymm1, ymmword ptr [rax+r9*8]
	inc r10d
	vmovupd ymm6, ymmword ptr [rax+r9*8+20h]
	vmovupd ymm2, ymmword ptr [r11+r9*8]
	vmovupd ymm7, ymmword ptr [r11+r9*8+20h]
	vmovupd ymm11, ymmword ptr [rax+r9*8+40h]
	vmovupd ymm12, ymmword ptr [r11+r9*8+40h]
	vcmppd ymm4, ymm0, ymm1, 1h
	vcmppd ymm9, ymm0, ymm6, 1h
	vcmppd ymm14, ymm0, ymm11, 1h
	vandpd ymm16, ymm1, ymm4
	vandpd ymm17, ymm6, ymm9
	vmulpd ymm3, ymm16, ymm2
	vmulpd ymm8, ymm17, ymm7
	vmovupd ymm1, ymmword ptr [rax+r9*8+60h]
	vmovupd ymm6, ymmword ptr [rax+r9*8+80h]
	vblendvpd ymm5, ymm2, ymm3, ymm4
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vmovupd ymm2, ymmword ptr [r11+r9*8+60h]
	vmovupd ymm7, ymmword ptr [r11+r9*8+80h]
	vmovupd ymmword ptr [rdx], ymm5
	vmovupd ymmword ptr [rdx+20h], ymm10
	vcmppd ymm4, ymm0, ymm1, 1h
	vcmppd ymm9, ymm0, ymm6, 1h
	vandpd ymm18, ymm11, ymm14
	vandpd ymm19, ymm1, ymm4
	vandpd ymm20, ymm6, ymm9
	vmulpd ymm13, ymm18, ymm12
	vmulpd ymm3, ymm19, ymm2
	vmulpd ymm8, ymm20, ymm7
	vmovupd ymm11, ymmword ptr [rax+r9*8+0a0h]
	vmovupd ymm1, ymmword ptr [rax+r9*8+0c0h]
	vmovupd ymm6, ymmword ptr [rax+r9*8+0e0h]
	vblendvpd ymm15, ymm12, ymm13, ymm14
	vblendvpd ymm5, ymm2, ymm3, ymm4
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vmovupd ymm12, ymmword ptr [r11+r9*8+0a0h]
	vmovupd ymm2, ymmword ptr [r11+r9*8+0c0h]
	vmovupd ymm7, ymmword ptr [r11+r9*8+0e0h]
	vmovupd ymmword ptr [rdx+40h], ymm15
	vmovupd ymmword ptr [rdx+60h], ymm5
	vmovupd ymmword ptr [rdx+80h], ymm10
	vcmppd ymm14, ymm0, ymm11, 1h
	vcmppd ymm4, ymm0, ymm1, 1h
	vcmppd ymm9, ymm0, ymm6, 1h
	vandpd ymm21, ymm11, ymm14
	add r9, 20h
	vandpd ymm22, ymm1, ymm4
	vandpd ymm23, ymm6, ymm9
	vmulpd ymm13, ymm21, ymm12
	vmulpd ymm3, ymm22, ymm2
	vmulpd ymm8, ymm23, ymm7
	vblendvpd ymm15, ymm12, ymm13, ymm14
	vblendvpd ymm5, ymm2, ymm3, ymm4
	vblendvpd ymm10, ymm7, ymm8, ymm9
	vmovupd ymmword ptr [rdx+0a0h], ymm15
	vmovupd ymmword ptr [rdx+0c0h], ymm5
	vmovupd ymmword ptr [rdx+0e0h], ymm10
	add rdx, 100h
	cmp r10d, r12d
	jb loop1

	vmovaps xmm6, xmmword ptr [rsp]
	vmovaps xmm7, xmmword ptr [rsp+16]
	vmovaps xmm8, xmmword ptr [rsp+32]
	vmovaps xmm9, xmmword ptr [rsp+48]
	vmovaps xmm10, xmmword ptr [rsp+64]
	vmovaps xmm11, xmmword ptr [rsp+80]
	vmovaps xmm12, xmmword ptr [rsp+96]
	vmovaps xmm13, xmmword ptr [rsp+112]
	vmovaps xmm14, xmmword ptr [rsp+128]
	vmovaps xmm15, xmmword ptr [rsp+144]

	add rsp, 168
	pop r12
	pop rbx

	vzeroupper
	ret
mul_blend_avx ENDP
end