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

;	.globl vrsqrtps_newt_avx

	; void vrsqrtps_newt_avx(float *in, float *out, size_t len)
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = len


_RDATA SEGMENT    READ ALIGN(32) 'DATA'

half REAL4 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5
three REAL4 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0

_RDATA ENDS

.code
vrsqrtps_newt_avx PROC public

	push rbx

	mov rax, rcx
	mov rbx, rdx
	mov rcx, r8
	shl rcx, 2    ; rcx is size of inputs in bytes
	xor r8, r8

	vmovups ymm3, three
	vmovups ymm4, half

loop1:
	vmovups ymm5, [rax+r8]
	vrsqrtps ymm0, ymm5
	vmulps ymm2, ymm0, ymm0
	vmulps ymm2, ymm2, ymm5
	vsubps ymm2, ymm3, ymm2
	vmulps ymm0, ymm0, ymm2
	vmulps ymm0, ymm0, ymm4
	vmovups [rbx+r8], ymm0
	add r8, 32
	cmp r8, rcx
	jl loop1

	vzeroupper
	pop rbx
	ret
vrsqrtps_newt_avx ENDP
end
