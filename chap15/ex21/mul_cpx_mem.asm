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

;	.globl mul_cpx_mem

	; void mul_cpx_mem(complex_num *in1, complex_num *in2, complex_num *out, size_t len);
	; On entry:
	;     rcx = in1
	;     rdx = in2
	;     r8 = out
	;     r9 = len


.code
mul_cpx_mem PROC public

	push rbx
	sub rsp, 32
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7

	mov rax, rcx    ; mov rax, inPtr1
	mov rbx, rdx    ; mov rbx, inPtr2
	                ; mov rdx, outPtr  (rdx already contains the out array)
	mov r10, r9     ; mov r8, len

	xor r9, r9

loop1:
	vmovaps ymm0, [rax +8*r9]
	vmovaps ymm4, [rax +8*r9 +32]
	vmovsldup ymm2, ymmword ptr[rbx +8*r9]
	vmulps ymm2, ymm2, ymm0
	vshufps ymm0, ymm0, ymm0, 177
	vmovshdup ymm1, ymmword ptr[rbx +8*r9]
	vmulps ymm1, ymm1, ymm0
	vmovsldup ymm6, ymmword ptr[rbx +8*r9 +32]
	vmulps ymm6, ymm6, ymm4
	vaddsubps ymm3, ymm2, ymm1
	vmovshdup ymm5, ymmword ptr[rbx +8*r9 +32]
	vmovaps [r8 +8*r9], ymm3
	vshufps ymm4, ymm4, ymm4, 177
	vmulps ymm5, ymm5, ymm4
	vaddsubps ymm7, ymm6, ymm5
	vmovaps [r8 +8*r9 +32], ymm7
	add r9, 8
	cmp r9, r10
	jl loop1

	vzeroupper
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp], xmm6
	add rsp, 32
	pop rbx
	ret
mul_cpx_mem ENDP
end