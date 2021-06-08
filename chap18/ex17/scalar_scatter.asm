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


;	.globl scalar_scatter

	; void scalar_scatter(const uint64_t *input, const uint32_t *indices, uint64_t count, float *output);
	;
	; On entry:
	;     rcx = input
	;     rdx = indices
	;     r8 = count
	;     r9 = output


.code
scalar_scatter PROC public

	push rbx

	mov rax, rcx					; mov rax, pImage // input
							; mov r9, pOutImage //output
	mov rbx, rdx					; mov rbx, pIndex //indexes
							; mov rdx, len //length

	xor r10, r10

mainloop:
	mov r10d, [rbx+r8-4h]
	vcvtsi2ss xmm0, xmm0, qword ptr [rax+r8*2-8h]
	vmovss DWORD PTR [r9+r10*4], xmm0
	sub r8, 4
	jnz mainloop

	pop rbx
	ret
scalar_scatter ENDP
end