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


;	.globl hardware_scatter

	; void hardware_scatter(const uint64_t *input, const uint32_t *indices, uint64_t count, float *output);
	;
	; On entry:
	;     rcx = input
	;     rdx = indices
	;     r8 = count
	;     r9 = output


.code
hardware_scatter PROC public

	push rbx

	mov rax, rcx					; mov rax, pImage // input
							; mov r9, pOutImage //output
	mov rbx, rdx					; mov rbx, pIndex //indexes
							; mov r8, len //length

mainloop:
	vmovdqa32 zmm0, [rbx+r8-40h]
	vmovdqa32 zmm1, [rax+r8*2-80h]
	vcvtuqq2ps ymm1, zmm1
	vmovdqa32 zmm2, [rax+r8*2-40h]
	vcvtuqq2ps ymm2, zmm2
	vshuff32x4 zmm1, zmm1, zmm2, 44h
	kxnorw k1,k1,k1
	vscatterdps [r9+4*zmm0] {k1}, zmm1
	sub r8, 40h
	jnz mainloop

	vzeroupper
	pop rbx
	ret
hardware_scatter ENDP
end