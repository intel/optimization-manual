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

;	.globl median_avx_overlap

	; void median_avx_overlap(float *x, float *y, uint64_t len);
	; On entry:
	;     rcx = x
	;     rdx = y
	;     r8 = len

.code
median_avx_overlap PROC public

	push rbx

	xor ebx, ebx
	;mov rcx, rdx   ; mov rcx, len

	; rcx and rdx already point to x and y the inputs and outputs
	; mov rcx, inPtr
	; mov rdx, outPtr

	vmovaps ymm0, [rcx]
loop_start:
	vshufps ymm2, ymm0, [rcx+16], 4Eh
	vshufps ymm1, ymm0, ymm2, 99h
	add rbx, 8
	add rcx, 32
	vminps ymm4, ymm0, ymm1
	vmaxps ymm0, ymm0, ymm1
	vminps ymm3, ymm0, ymm2
	vmaxps ymm5, ymm3, ymm4
	vmovaps [rdx], ymm5
	add rdx, 32
	vmovaps ymm0, [rcx]
	cmp rbx, r8
	jl loop_start

	vzeroupper
	pop rbx
	ret
median_avx_overlap ENDP
end
