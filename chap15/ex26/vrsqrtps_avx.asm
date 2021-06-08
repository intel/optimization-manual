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

;	.globl vrsqrtps_avx

	; void vrsqrtps_avx(float *in, float *out, size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


.code
vrsqrtps_avx PROC public

	push rbx

	mov rax, rcx
	mov rbx, rdx
	mov rcx, r8
	shl rcx, 2    ; rcx is size of inputs in bytes
	xor r8, r8

loop1:
	vrsqrtps ymm0, [rax+r8]
	vmovups [rbx+r8], ymm0
	add r8, 32
	cmp r8, rcx
	jl loop1

	vzeroupper
	pop rbx
	ret
vrsqrtps_avx ENDP
end