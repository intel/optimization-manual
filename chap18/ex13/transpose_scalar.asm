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

;	.globl transpose_scalar

	; void transpose_scalar(uint16_t *out, const uint16_t *in)
	; On entry:
	;     rcx = out
	;     rdx = in


.code
transpose_scalar PROC Public

	push rbx

					; mov rdx, pImage
					; mov rcx, pOutImage
	xor r9, r9
matrix_loop:
	xor rax, rax
outerloop:
	xor rbx, rbx
innerloop:
	mov r10, rax
	shl r10, 3
	add r10, rbx
	mov r8w, word ptr [rdx+r10*2]
	mov r10, rbx
	shl r10, 3
	add r10, rax
	mov word ptr [rcx+r10*2], r8w
	add rbx, 1
	cmp rbx, 8
	jne innerloop
	add rax, 1
	cmp rax, 8
	jne outerloop
	add r9, 1
	add rdx, 64*2
	add rcx, 64*2
	cmp r9, 50
	jne matrix_loop

	pop rbx
	ret
transpose_scalar ENDP
end