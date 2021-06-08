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

;	.globl lookup128_vbmi

	; void lookup128_vbmi(const uint8_t *in, uint8_t* dict, uint8_t *out, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = dict
	;     r8 = out
	;     r9 = len


.code
lookup128_vbmi PROC public
	                              ; mov rdx, dictionary_bytes
	mov r11, rcx                  ; mov r11, in_bytes
	mov rax, r8                   ; mov rax, out_bytes
	                              ; mov r9d, numOfElements
	xor r8, r8
	vmovdqu32 zmm2, [rdx]
	vmovdqu32 zmm3, [rdx+64]
lp:
	vmovdqu32 zmm1, [r11+r8*1]
	vpermi2b zmm1, zmm2, zmm3
	vmovdqu32 [rax+r8*1], zmm1
	add r8, 64
	cmp r8, r9
	jl lp

	vzeroupper
	ret
lookup128_vbmi ENDP
end