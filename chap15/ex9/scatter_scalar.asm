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

;	.globl scatter_scalar

	; void scatter_scalar(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = index
	;     r9 = len

.code
scatter_scalar PROC public

	push rbx

	; registers are already initialised correctly.
	; mov rcx, InBuf
	; mov rdx, OutBuf
	; mov r8, Index
	mov r10, r9

	xor r9, r9
loop1:
	movsxd rax, dword ptr[r8]
	mov ebx, [rcx]
	mov [rdx + 4*rax], ebx
	movsxd rax, dword ptr[r8 + 4]
	mov ebx, [rcx + 4]
	mov [rdx + 4*rax], ebx
	movsxd rax, dword ptr[r8 + 8]
	mov ebx, [rcx + 8]
	mov [rdx + 4*rax], ebx
	movsxd rax, dword ptr[r8 + 12]
	mov ebx, [rcx + 12]
	mov [rdx + 4*rax], ebx
	movsxd rax, dword ptr[r8 + 16]
	mov ebx, [rcx + 16]
	mov [rdx + 4*rax], ebx
	movsxd rax, dword ptr[r8 + 20]
	mov ebx, [rcx + 20]
	mov [rdx + 4*rax], ebx
	movsxd rax, dword ptr[r8 + 24]
	mov ebx, [rcx + 24]
	mov [rdx + 4*rax], ebx
	movsxd rax, dword ptr[r8 + 28]
	mov ebx, [rcx + 28]
	mov [rdx + 4*rax], ebx
	add rcx, 32
	add r8, 32
	add r9, 8
	cmp r9, r10
	jl loop1

	pop rbx
	ret
scatter_scalar ENDP
end