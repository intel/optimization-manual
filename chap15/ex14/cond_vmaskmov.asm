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

;	.globl cond_vmaskmov

	; void cond_vmaskmov(float *a, float *b, float *d, float *c, float *e, size_t len);
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = d
	;     r9 = c
	;     [rsp+48] = e
	;     [rsp+56] = len

.code
cond_vmaskmov PROC public
	push rbx

	mov rax, rcx                ; mov rax, pA
;	mov rbx, rdx                ; mov rbx, pB
	                            ; mov rcx, pC
	                            ; mov rdx, pD
	mov rbx, qword ptr[rsp+48]  ; mov rbx, pE
	mov r11, qword ptr[rsp+56]   ; mov r11, len
	shl r11, 2                   ; each element occupies 4 bytes

	; ymm0 all zeros
	vxorps ymm0, ymm0, ymm0
	;  ymm3 all ones
	vcmpps ymm3, ymm0, ymm0, 0
	xor r10, r10
loop1:
	vmovups ymm1, [rax+r10]
	vcmpps ymm2, ymm0, ymm1, 1
	vmaskmovps ymm4, ymm2, [r9+r10]
	vxorps ymm2, ymm2, ymm3
	vmaskmovps ymm5, ymm2, [r8+r10]
	vorps ymm4, ymm4, ymm5
	vmulps ymm4, ymm4, [rbx+r10]
	vmovups [rdx+r10], ymm4
	add r10, 32
	cmp r10, r11
	jl loop1

	pop rbx
	ret
cond_vmaskmov ENDP
end