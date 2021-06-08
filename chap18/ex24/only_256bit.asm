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


;	.globl only_256bit

	; void only_256bit(uint64_t count);
	; On entry: 
	;     rcx = count


.code
only_256bit PROC public

	mov rdx, rsp
	and rsp, -10h
	sub rsp, 160
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

	mov rax, 33
	push rax

Loop1:
	vpbroadcastd ymm0, dword ptr [rsp]
	vfmadd213ps ymm7, ymm7, ymm7
	vfmadd213ps ymm8, ymm8, ymm8
	vfmadd213ps ymm9, ymm9, ymm9
	vfmadd213ps ymm10, ymm10, ymm10
	vfmadd213ps ymm11, ymm11, ymm11
	vfmadd213ps ymm12, ymm12, ymm12
	vfmadd213ps ymm13, ymm13, ymm13
	vfmadd213ps ymm14, ymm14, ymm14
	vfmadd213ps ymm15, ymm15, ymm15
	vfmadd213ps ymm16, ymm16, ymm16
	vfmadd213ps ymm17, ymm17, ymm17
	vfmadd213ps ymm18, ymm18, ymm18
	vpermd ymm1, ymm1, ymm1
	vpermd ymm2, ymm2, ymm2
	vpermd ymm3, ymm3, ymm3
	vpermd ymm4, ymm4, ymm4
	vpermd ymm5, ymm5, ymm5
	vpermd ymm6, ymm6, ymm6
	dec rcx
	jnle Loop1

	pop rax

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
	
	mov rsp, rdx

	ret
only_256bit ENDP
end