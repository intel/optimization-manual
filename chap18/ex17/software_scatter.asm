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


;	.globl software_scatter

	; void software_scatter(const uint64_t *input, const uint32_t *indices, uint64_t count, float *output);
	;
	; On entry:
	;     rcx = input
	;     rdx = indices
	;     r8 = count
	;     r9 = output


_RDATA SEGMENT    READ ALIGN(32) 'DATA'

	shufMaskP   DQ 0000000200000001h
				DQ 0000000400000003h
				DQ 0000000600000005h
				DQ 0000000800000007h

_RDATA ENDS

.code
software_scatter PROC public

	push rbx

	mov rax, rcx					; mov rax, pImage // input
							; mov r9, pOutImage //output
	mov rbx, rdx					; mov rbx, pIndex //indexes
							; mov r8, len //length


	lea r10, ymmword ptr shufMaskP			; mov r10, shufMaskP
	vmovaps ymm2, [r10]

mainloop:
	vmovaps zmm1, [rax + r8*2 - 80h] 		; load data
	vcvtuqq2ps ymm0, zmm1 				; convert to float
	movsxd r10, DWORD PTR [rbx + r8 - 40h] 			; load 8th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 3ch] 			; load 7th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 38h] 			; load 6th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 34h] 			; load 5th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 30h]			; load 4th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 2ch] 			; load 3rd index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 28h] 			; load 2nd index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 24h] 			; load 1st index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vmovaps zmm1, [rax + r8*2 - 40h] 		; load data
	vcvtuqq2ps ymm0, zmm1 				; convert to float
	movsxd r10, DWORD PTR [rbx + r8 - 20h] 			; load 8th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 1ch] 			; load 7th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 18h] 			; load 6th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 14h] 			; load 5th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 10h] 			; load 4th index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 0ch] 			; load 3rd index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 08h] 			; load 2nd index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	vpermd ymm0, ymm2, ymm0
	movsxd r10, DWORD PTR [rbx + r8 - 04h]			; load 1st index
	vmovss DWORD PTR [r9 + 4*r10], xmm0
	sub r8, 40h
	jnz mainloop

	vzeroupper
	pop rbx
	ret

software_scatter ENDP
end
