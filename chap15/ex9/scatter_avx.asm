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

;	.globl scatter_avx

	; void scatter_avx(int32_t *in, int32_t *out, unt32_t *index, size_t len);
	; On entry:
	;    rcx = in
	;    rdx = out
	;    r8 = index
	;    r9 = len

.code
scatter_avx PROC public

	push rbx

	; registers are already initialised correctly.
	; mov rcx, InBuf
	; mov rdx, OutBuf
	; mov r8, Index
	mov r10, r9

	xor r9, r9
loop1:
	vmovaps ymm0, [rcx + 4*r9]
	movsxd rax, dword ptr[r8 + 4*r9]
	movsxd rbx, dword ptr[r8 + 4*r9 + 4]
	vmovss dword ptr[rdx + 4*rax], xmm0
	movsxd rax, dword ptr[r8 + 4*r9 + 8]
	vpalignr xmm1, xmm0, xmm0, 4

	vmovss dword ptr[rdx + 4*rbx], xmm1
	movsxd rbx, dword ptr[r8 + 4*r9 + 12]
	vpalignr xmm2, xmm0, xmm0, 8
	vmovss dword ptr[rdx + 4*rax], xmm2
	movsxd rax, dword ptr[r8 + 4*r9 + 16]
	vpalignr xmm3, xmm0, xmm0, 12
	vmovss dword ptr[rdx + 4*rbx], xmm3
	movsxd rbx, dword ptr[r8 + 4*r9 + 20]
	vextractf128 xmm0, ymm0, 1
	vmovss dword ptr[rdx + 4*rax], xmm0
	movsxd rax, dword ptr[r8 + 4*r9 + 24]
	vpalignr xmm1, xmm0, xmm0, 4
	vmovss dword ptr[rdx + 4*rbx], xmm1
	movsxd rbx, dword ptr[r8 + 4*r9 + 28]
	vpalignr xmm2, xmm0, xmm0, 8
	vmovss dword ptr[rdx + 4*rax], xmm2
	vpalignr xmm3, xmm0, xmm0, 12
	vmovss dword ptr[rdx + 4*rbx], xmm3
	add r9, 8
	cmp r9, r10
	jl loop1

	vzeroupper
	pop rbx
	ret
scatter_avx ENDP
end