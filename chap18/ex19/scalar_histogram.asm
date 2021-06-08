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


;	.globl scalar_histogram

	; void scalar_histogram(const int32_t *input, uint32_t *output, uint64_t num_inputs, uint64_t bins);
	;
	; On entry:
	;     rcx = input
	;     rdx = ouptut
	;     r8 = num_inputs
	;     r9 = bins


.code
scalar_histogram PROC public

	push rbx

	mov r10d, r9d			; mov r10d, bins_minus_1
	dec r10d
					; mov r8, num_inputs
	shr r8d, 1
					; mov rcx, pInput
	mov r11, rdx			; mov r11, pHistogram
	xor rax, rax

histogram_loop:
	lea r9d, [rax + rax]
	inc eax
	movsxd r9, r9d
	mov edx, [rcx+r9*4]
	and edx, r10d
	mov ebx, [rcx+r9*4+4]
	movsxd rdx, edx
	and ebx, r10d
	movsxd rbx, ebx
	inc dword ptr [r11+rdx*4]
	inc dword ptr [r11+rbx*4]
	cmp eax, r8d
	jb histogram_loop

	pop rbx

	ret
scalar_histogram ENDP
end
