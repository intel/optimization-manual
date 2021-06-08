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

;	.globl mask_avx512

;	# void mask_avx512(uint32_t *a, uint32_t *b, size_t N);
;	# On entry:
;	#     rcx = a
;	#     rdx = b
;	#     r8 = N


.code
mask_avx512 PROC public

;	push rbx

;	mov rax,rcx                        ; mov rax,a
;	mov rbx,rdx                        ; mov rbx,b
	                                   ; mov r8,size2
loop1:
	vmovdqa32 zmm1,[rcx +r8*4 -40h]
	vmovdqa32 zmm2,[rdx +r8*4 -40h]
	vpcmpgtd k1,zmm1,zmm2
	vmovdqa32 zmm3{k1}{z},zmm2
	vpaddd zmm1,zmm1,zmm3
	vmovdqa32 [rcx +r8*4 -40h],zmm1
	sub r8,16
	jne loop1

;	pop rbx
	vzeroupper
	ret

mask_avx512 ENDP
end