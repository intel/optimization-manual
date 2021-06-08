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


;	.globl manual_rounding

	; void void manual_rounding(const float *a, const float *b, float* out);
	;
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = out


.code
manual_rounding PROC public

	vmovups zmm2, [rcx]
	vmovups zmm4, [rdx]
	push rbx

	mov ebx, 0ffffh
	kmovw k6, ebx

	sub rsp, 4
	mov rax, rsp
	sub rsp, 4
	mov r10, rsp

	; rax & r10 point to temporary dword values in memory used to load and save (for restoring) MXCSR value exceptions

	vstmxcsr DWORD PTR [rax] 			; load mxcsr value to memory
	mov ebx, [rax] 			; move to register
	and ebx, 0FFFF9FFFh 		; zero RM bits
	or ebx, 5F80h			; put {ru} to RM bits and suppress all
	mov [r10], ebx			; move new value to the memory
	vldmxcsr DWORD PTR [r10]			; save to MXCSR

	vaddps zmm7 {k6}, zmm2, zmm4 	; operation itself
	vldmxcsr DWORD PTR [rax] 			; restore previous MXCSR value

	vmovups [r8], zmm7

	add rsp, 8
	pop rbx
	vzeroupper
	ret
manual_rounding ENDP
end