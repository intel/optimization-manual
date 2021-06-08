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

;	.globl mce_scalar

	; void mce_scalar(uint32_t *out, const uint32_t *in, uint64_t width)
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = width (must be > 0)


.code
mce_scalar PROC public

	push rbx

	                    ; mov rdx, pImage
	                    ; mov rcx, pOutImage
	mov rbx, r8	        ; mov rbx, len
	xor rax, rax

mainloop:
	mov r10d, dword ptr [rdx+rax*4]
	mov r9d, r10d
	cmp r10d, 0
	jle label1
	and r9d, 03h
	cmp r9d, 3
	jne label1
	add r10d, 5
label1:
	mov dword ptr [rcx+rax*4], r10d
	add rax, 1
	cmp rax, rbx
	jne mainloop

	pop rbx
	ret
mce_scalar ENDP
end