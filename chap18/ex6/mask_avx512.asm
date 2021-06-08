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

;	# void mask_avx512(uint32_t *a, uint32_t *b, uint32_t *c, size_t N);
;	# On entry:
;	#     rcx = a
;	#     rdx = b
;	#     r8 = c
;	#     r9 = N


.code
mask_avx512 PROC public

	push rbx

	mov rax, r9

;	mov rax, rcx       ; mov rax, pImage
	mov rbx, rdx       ; mov rbx, pImage1
	mov r9, r8         ; mov r9, pOutImage
	mov r8, rax        ; mov r8, len

	vpxord zmm0, zmm0, zmm0
mainloop:
	vmovdqa32 zmm2, [rcx+r8*4-40h]
	vmovdqa32 zmm1, [rbx+r8*4-40h]
	vpcmpgtd k1, zmm1, zmm0
	knotw k2, k1
	vpslld zmm2 {k1}, zmm2, 1
	vpsrld zmm2 {k2}, zmm2, 1
	vmovdqa32 [r9+r8*4-40h], zmm2
	sub r8, 16
	jne mainloop

	pop rbx
	vzeroupper
	ret
mask_avx512 ENDP
end