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

;	.globl mce_avx2

	; void mce_avx2(uint32_t *out, const uint32_t *in, uint64_t width)
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = width (must be > 0 and a multiple of 8)


	.data
	ALIGN 4

five DD 5
three DD 3

.code
mce_avx2 PROC public

	push rbx
	sub rsp, 16
	vmovaps xmmword ptr[rsp], xmm6
	                               ; mov rdx, pImage
	                               ; mov rcx, pOutImage
	mov rbx, r8	               ; mov rbx, [len]
	xor rax, rax

	vpbroadcastd ymm1, five   ; vpbroadcastd ymm1, [five]
	vpbroadcastd ymm2, three  ; vpbroadcastd ymm2, [three]
	vpxor ymm3, ymm3, ymm3
mainloop:
	vmovdqa ymm0, ymmword ptr[rdx+rax*4]
	vmovaps ymm6, ymm0
	vpcmpgtd ymm5, ymm0, ymm3
	vpand ymm6, ymm6, ymm2
	vpcmpeqd ymm6, ymm6, ymm2
	vpand ymm5, ymm5, ymm6
	vpaddd ymm4, ymm0, ymm1
	vblendvps ymm4, ymm0, ymm4, ymm5
	vmovdqa ymmword ptr[rcx+rax*4], ymm4
	add rax, 8
	cmp rax, rbx
	jne mainloop

	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 16
	pop rbx
	vzeroupper

	ret

mce_avx2 ENDP
end