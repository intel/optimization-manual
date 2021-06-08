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

;	.globl avx_vinsert

	; void avx_vinsert(size_t len, uint32_t* index_buffer, double* imaginary_buffer,
	;                   double* real_buffer, complex_num* complex_buffer);
	; On entry:
	;     rcx = len (length in elements of )
	;     rdx = index_buffer
	;     r8 = imaginary_buffer
	;     r9 = real_buffer
	;     [rsp+48]  = complex_buffer


.code
avx_vinsert PROC public
	push rbx
	mov rbx, qword ptr[rsp+48]
	xor rax, rax

loop_start:
	movsxd r10, dword ptr [rdx+rax*4]
	shl r10, 4
	movsxd r11, dword ptr [rdx+rax*4+8]
	shl r11, 4
	vmovupd xmm0, xmmword ptr [rbx+r10*1]
	movsxd r10, dword ptr [rdx+rax*4+4]
	shl r10, 4
	vinsertf128 ymm2, ymm0, xmmword ptr [rbx+r11*1], 1
	vmovupd xmm1, xmmword ptr [rbx+r10*1]
	movsxd r10, dword ptr [rdx+rax*4+0ch]
	shl r10, 4
	vinsertf128 ymm3, ymm1, xmmword ptr [rbx+r10*1], 1
	movsxd r10, dword ptr [rdx+rax*4+10h]
	shl r10, 4
	vunpcklpd ymm4, ymm2, ymm3
	vunpckhpd ymm5, ymm2, ymm3
	vmovupd ymmword ptr [r9], ymm4
	vmovupd xmm6, xmmword ptr [rbx+r10*1]
	vmovupd ymmword ptr [r8], ymm5
	movsxd r10, dword ptr [rdx+rax*4+18h]
	shl r10, 4
	vinsertf128 ymm8, ymm6, xmmword ptr [rbx+r10*1], 1
	movsxd r10, dword ptr [rdx+rax*4+14h]
	shl r10, 4
	vmovupd xmm7, xmmword ptr [rbx+r10*1]
	movsxd r10, dword ptr [rdx+rax*4+1ch]
	add rax, 8
	shl r10, 4
	vinsertf128 ymm9, ymm7, xmmword ptr [rbx+r10*1], 1
	vunpcklpd ymm10, ymm8, ymm9
	vunpckhpd ymm11, ymm8, ymm9
	vmovupd ymmword ptr [r9+20h], ymm10
	add r9, 40h
	vmovupd ymmword ptr [r8+20h], ymm11
	add r8, 40h
	cmp rax, rcx
	jl loop_start

	vzeroupper
	pop rbx
	ret
avx_vinsert ENDP
end