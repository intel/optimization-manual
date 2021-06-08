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
	
	;.globl transform_avx

	; void transform_avx(float *cos_sin_teta_vec, float *sin_cos_teta_vec, float *in, float *out, size_t len);
	; On entry:
	;     rcx = cos_sin_teta_vec
	;     rdx = sin_cos_teta_vec
	;     r8 = in
	;     r9 = out
	;     [rsp+48] = len

.code
transform_avx PROC public

	push rbx

	mov rax, r8 ; mov rax, pInVector
	mov rbx, r9 ; mov rbx, pOutVector

	; Load into an ymm register of 32 bytes
	vmovups ymm3, ymmword ptr[rcx]; vmovups ymm3, ymmword ptr[cos_sin_teta_vec]
	vmovups ymm4, ymmword ptr[rdx]; vmovups ymm4, ymmword ptr[sin_cos_teta_vec]
	mov rdx, qword ptr[rsp+48] ; mov rdx, len
	shl rdx, 2  ; size of input array in bytes
	xor rcx, rcx

loop1:
	vmovsldup ymm0, ymmword ptr[rax+rcx]
	vmovshdup ymm1, ymmword ptr[rax+rcx]
	; example: vmulps has 3 operands
	vmulps ymm0, ymm0, ymm3
	vmulps ymm1, ymm1, ymm4
	vaddsubps ymm0, ymm0, ymm1
	; 32 byte store from an ymm register
	vmovaps [rbx+rcx], ymm0
	vmovsldup ymm0, ymmword ptr[rax+rcx+32]
	vmovshdup ymm1, ymmword ptr[rax+rcx+32]
	vmulps ymm0, ymm0, ymm3
	vmulps ymm1, ymm1, ymm4
	vaddsubps ymm0, ymm0, ymm1
	; offset of 32 bytes from previous store
	vmovaps [rbx+rcx+32], ymm0
	; Processed 64bytes in this loop
	; (The code is unrolled twice)
	add rcx, 64
	cmp rcx, rdx
	jl loop1

	vzeroupper
	pop rbx
	ret
transform_avx ENDP
end

