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

;globl transform_sse

	; void transform_sse(float *cos_sin_teta_vec, float *sin_cos_teta_vec, float *in, float *out, size_t len);
	; On entry:
	;     rcx = cos_sin_teta_vec
	;     rdx = sin_cos_teta_vec
	;     r8 = in
	;     r9 = out
	;     [rsp+48] = len

.code 

transform_sse PROC public

	push rbx

	mov rax, r8 ; mov rax, pInVector
	mov rbx, r9 ; mov rbx, pOutVector
	
	; Load into an xmm register of 16 bytes
	movups xmm3, xmmword ptr[rcx] ; movups xmm3, xmmword ptr[cos_sin_teta_vec]
	movups xmm4, xmmword ptr[rdx] ; movups xmm4, xmmword ptr[sin_cos_teta_vec]
	mov rdx, qword ptr[rsp+48] ; mov rdx, len
	shl rdx, 2  ; size of input array in bytes
	xor rcx, rcx

loop1:
	movsldup xmm0, [rax+rcx]
	movshdup xmm1, [rax+rcx]
	; example: mulps has 2 operands
	mulps xmm0, xmm3
	mulps xmm1, xmm4
	addsubps xmm0, xmm1
	; 16 byte store from an xmm register
	movaps [rbx+rcx], xmm0
	
	movsldup xmm0, [rax+rcx+16]
	movshdup xmm1, [rax+rcx+16]
	mulps xmm0, xmm3
	mulps xmm1, xmm4
	addsubps xmm0, xmm1
	; offset of 16 bytes from previous store
	movaps [rbx+rcx+16], xmm0
	; Processed 32bytes in this loop
	; (The code is unrolled twice)
	add rcx, 32
	cmp rcx, rdx
	jl loop1

	pop rbx
	ret
transform_sse ENDP
end