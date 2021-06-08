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

;	.globl mce_avx512

	; void mce_avx512(uint32_t *out, const uint32_t *in, uint64_t width)
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = width (must be > 0 and a multiple of 8)


	.data
	ALIGN 4

five DD 5
three DD 3

.code
mce_avx512 PROC public

	push rbx

	                               ; mov rdx, pImage
	                               ; mov rcx, pOutImage
	mov rbx, r8                    ; mov rbx, [len]
	xor rax, rax

	vpbroadcastd zmm1, five
	vpbroadcastd zmm5, three
	vpxord zmm3, zmm3, zmm3
mainloop:
	vmovdqa32 zmm0, [rdx+rax*4]
	vpcmpgtd k1, zmm0, zmm3
	vpandd zmm2, zmm5, zmm0
	vpcmpeqd k2, zmm2, zmm5
	kandw k1, k2, k1
	vpaddd zmm0 {k1}, zmm0, zmm1
	vmovdqa32 [rcx+rax*4], zmm0
	add rax, 16
	cmp rax, rbx
	jne mainloop

	pop rbx
	vzeroupper

	ret

mce_avx512 ENDP
end