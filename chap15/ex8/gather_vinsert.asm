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

;	.globl gather_vinsert

	; void gather_vinsert(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = out
	;     r8 = index
	;     r9 = len

.code
gather_vinsert PROC public

	push rbx

	; registers are already initialised correctly.
	; mov rcx, InBuf
	; mov rdx, OutBuf
	; mov r8, Index
	mov r10, r9

	xor r9, r9
loop1:
	mov rax, [r8 + 4*r9]
	movsxd rbx, eax
	sar rax, 32
	vmovss xmm1, dword ptr[rcx + 4*rbx]
	vinsertps xmm1, xmm1, dword ptr[rcx + 4*rax], 16
	mov rax, [r8 + 8 + 4*r9]
	movsxd rbx, eax
	sar rax, 32
	vinsertps xmm1, xmm1, dword ptr[rcx + 4*rbx], 32
	vinsertps xmm1, xmm1, dword ptr[rcx + 4*rax], 48
	mov rax, [r8 + 16 + 4*r9]
	movsxd rbx, eax
	sar rax, 32
	vmovss xmm2, dword ptr[rcx + 4*rbx]
	vinsertps xmm2, xmm2, dword ptr[rcx + 4*rax], 16
	mov rax,[r8 + 24 + 4*r9]
	movsxd rbx, eax
	sar rax, 32
	vinsertps xmm2, xmm2, dword ptr[rcx + 4*rbx], 32
	vinsertps xmm2, xmm2, dword ptr[rcx + 4*rax], 48
	vinsertf128 ymm1, ymm1, xmm2, 1
	vmovaps [rdx + 4*r9], ymm1
	add r9, 8
	cmp r9, r10 ; cmp rcx, len
	jl loop1

	vzeroupper
	pop rbx
	ret
gather_vinsert ENDP
end