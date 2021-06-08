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

;	.globl vrcpps_avx

	; void vrcpps_avx(float *in1, float *in2, float *out, size_t len)
	; On entry:
	;     rcx = in1
	;     rdx = in2
	;     r8 = out
	;     r9 = len


.code
vrcpps_avx PROC public

	push rbx

	mov rax, rcx
	mov rbx, rdx
	mov rdx, r9
	shl rdx, 2    ; rdx is size of inputs in bytes
	mov r9, r8
	xor r8, r8

loop1:
	vmovups ymm0, [rax+r8]
	vmovups ymm1, [rbx+r8]
	vrcpps ymm1, ymm1
	vmulps ymm0, ymm0, ymm1
	vmovups [r9+r8], ymm0
	add r8, 32
	cmp r8, rdx
	jl loop1

	vzeroupper
	pop rbx
	ret
vrcpps_avx ENDP
end