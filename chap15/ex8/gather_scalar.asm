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

;	.globl gather_scalar

	; void gather_scalar(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = index
	;     r9 = len

.code
gather_scalar PROC public

	push rbx

	; registers are already initialised correctly.
	; mov rcx, InBuf
	; mov rdx, OutBuf
	; mov r8, Index
	mov r10, r9

	xor r9, r9
loop1:
	mov rax, [r8]
	movsxd rbx, eax
	sar rax, 32
	mov ebx,[rcx + 4*rbx]
	mov [rdx], ebx
	mov eax,[rcx + 4*rax]
	mov [rdx + 4], eax
	mov rax, [r8 + 8]
	movsxd rbx, eax
	sar rax, 32
	mov ebx, [rcx + 4*rbx]
	mov [rdx + 8], ebx
	mov eax,[rcx + 4*rax]
	mov [rdx + 12], eax
	mov rax, [r8 + 16]
	movsxd rbx, eax
	sar rax, 32
	mov ebx, [rcx + 4*rbx]
	mov [rdx + 16], ebx
	mov eax, [rcx + 4*rax]
	mov [rdx + 20], eax
	mov rax, [r8 + 24]
	movsxd rbx, eax
	sar rax, 32
	mov ebx, [rcx + 4*rbx]
	mov [rdx + 24], ebx
	mov eax, [rcx + 4*rax]
	mov [rdx + 28], eax
	add rdx, 32
	add r8, 32
	add r9, 8
	cmp r9, r10             ; cmp rcx, len
	jl loop1

	pop rbx

	ret
gather_scalar ENDP
end