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

;	.globl transform_avx

;	# void transform_avx(float *cos_sin_teta_vec, float *sin_cos_teta_vec,
;	#	float *in, float *out, size_t len);
;	# On entry:
;	#     rcx = cos_sin_teta_vec
;	#     rdx = sin_cos_teta_vec
;	#     r8 = in
;	#     r9 = out
;	#     [rsp+40] = len


.code
transform_avx PROC public

	mov r10, [rsp+40]

	mov rax, r8; mov rax,pInVector
	mov r11, r9 ; mov r11,pOutVector
;	# Load into a ymm register of 32 bytes
	vmovups ymm3, ymmword ptr[rcx]; vmovups ymm3, ymmword ptr[cos_sin_teta_vec]
	vmovups ymm4, ymmword ptr[rdx]; vmovups ymm4, ymmword ptr[sin_cos_teta_vec]

	mov r8d, r10d; mov edx, len
	shl r8d, 2
	xor r9d, r9d
loop1:
	vmovsldup ymm0, ymmword ptr [rax+r9]
	vmovshdup ymm1, ymmword ptr [rax+r9]
	vmulps ymm1, ymm1, ymm4
	vfmaddsub213ps ymm0, ymm3, ymm1
;	# 32 byte store from a ymm register
	vmovaps [r11+r9], ymm0
	vmovsldup ymm0, ymmword ptr [rax+r9+32]
	vmovshdup ymm1, ymmword ptr [rax+r9+32]
	vmulps ymm1, ymm1, ymm4
	vfmaddsub213ps ymm0, ymm3, ymm1
;	# offset 32 bytes from previous store
	vmovaps [r11+r9+32], ymm0
;	# Processed 64bytes in this loop
;	# (the code is unrolled twice)
	add r9d, 64
	cmp r9d, r8d
	jl loop1

	vzeroupper
	ret
transform_avx ENDP
end