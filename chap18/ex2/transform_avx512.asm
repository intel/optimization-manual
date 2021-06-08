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

;	.globl transform_avx512

;	# void transform_avx512(float *cos_sin_teta_vec, float *sin_cos_teta_vec,
;	#	float *in, float *out, size_t len);
;	# On entry:
;	#     rcx = cos_sin_teta_vec
;	#     rdx = sin_cos_teta_vec
;	#     r8 = in
;	#     r9 = out
;	#     [rsp+40] = len


.code
transform_avx512 PROC public

	mov r10, [rsp+40]

	mov rax, r8; mov rax,pInVector
	mov r11, r9 ; mov r11,pOutVector
;	# Load into a zmm register of 64 bytes
	vmovups zmm3, zmmword ptr[rcx]; vmovups zmm3, zmmword ptr[cos_sin_teta_vec]
	vmovups zmm4, zmmword ptr[rdx]; vmovups zmm4, zmmword ptr[sin_cos_teta_vec]
	mov r8d, r10d; mov edx, len
	shl r8d, 2
	xor r9d, r9d
loop1:
	vmovsldup zmm0, zmmword ptr [rax+r9]
	vmovshdup zmm1, zmmword ptr [rax+r9]
	vmulps zmm1, zmm1, zmm4
	vfmaddsub213ps zmm0, zmm3, zmm1
;	# 64 byte store from a zmm register
	vmovaps [r11+r9], zmm0
	vmovsldup zmm0, zmmword ptr [rax+r9+64]
	vmovshdup zmm1, zmmword ptr [rax+r9+64]
	vmulps zmm1, zmm1, zmm4
	vfmaddsub213ps zmm0, zmm3, zmm1
;	# offset 64 bytes from previous store
	vmovaps [r11+r9+64], zmm0
;	# Processed 128bytes in this loop
;	# (the code is unrolled twice)
	add r9d, 128
	cmp r9d, r8d
	jl loop1

	vzeroupper
	ret
transform_avx512 ENDP
end
