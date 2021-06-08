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

;	.globl mul_blend_avx512

;	# void mul_blend_avx512(double *a, double *b, double *c, size_t N);
;	# On entry:
;	#     rcx = a
;	#     rdx = b
;	#     r8 = c
;	#     r9 = N


.code
mul_blend_avx512 PROC public
;	// store non-volatile registers on stack
	push r12
	push rbx

	sub rsp, 56
	vmovaps  xmmword ptr[rsp], xmm6
	vmovaps  xmmword ptr[rsp+16], xmm7
	vmovaps  xmmword ptr[rsp+32], xmm8


	mov rax, rcx       ; mov rax, a
	mov r11, rdx       ; mov r11, b
	mov r12, r9        ; mov r12, N
	shr r12, 5
	mov rdx, r8       ; mov rdx, c

	xor r9, r9
	xor r10, r10
	mov rcx, 1
	cvtsi2sd xmm8, rcx
	vbroadcastsd zmm8, xmm8

loop1:
	vmovups zmm0, zmmword ptr[rax+r9*8]
	inc r10d
	vmovups zmm2, zmmword ptr[rax+r9*8+40h]
	vmovups zmm4, zmmword ptr[rax+r9*8+80h]
	vmovups zmm6, zmmword ptr[rax+r9*8+0c0h]
	vmovups zmm1, zmmword ptr[r11+r9*8]
	vmovups zmm3, zmmword ptr[r11+r9*8+40h]
	vmovups zmm5, zmmword ptr[r11+r9*8+80h]
	vmovups zmm7, zmmword ptr[r11+r9*8+0c0h]
	vcmppd k1, zmm8, zmm0, 1h
	vcmppd k2, zmm8, zmm2, 1h
	vcmppd k3, zmm8, zmm4, 1h
	vcmppd k4, zmm8, zmm6, 1h
	vmulpd zmm1{k1}, zmm0, zmm1
	vmulpd zmm3{k2}, zmm2, zmm3
	vmulpd zmm5{k3}, zmm4, zmm5
	vmulpd zmm7{k4}, zmm6, zmm7
	vmovups zmmword ptr [rdx], zmm1
	vmovups zmmword ptr [rdx+40h], zmm3
	vmovups zmmword ptr [rdx+80h], zmm5
	vmovups zmmword ptr [rdx+0c0h], zmm7
	add r9, 20h
	add rdx, 100h
	cmp r10d, r12d
	jb loop1


	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm8, xmmword ptr[rsp+32]
	add rsp, 56

	pop rbx
	pop r12
	vzeroupper
	ret
mul_blend_avx512 ENDP
end