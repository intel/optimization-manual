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

;	.globl scalar_compress

	; uint64_t scalar_compress(uint32_t *out, const uint32_t *in, uint64_t len)
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = len

	; On exit
	;     rax = out_len


.code
scalar_compress PROC public
	                                   ; mov rdx, source
	                                   ; mov rcx, dest
	mov r9, r8                         ; mov r9, len
	xor r8, r8
	xor r10, r10

mainloop:
	mov r11d, dword ptr [rdx+r8*4]
	test r11d, r11d
	jle m1
	mov dword ptr [rcx+r10*4], r11d
	inc r10
m1:
	inc r8
	cmp r8, r9
	jne mainloop

	mov rax, r10

	ret
scalar_compress ENDP
end