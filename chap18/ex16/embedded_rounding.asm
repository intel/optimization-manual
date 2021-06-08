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


;	.globl embedded_rounding

	; void void embedded_rounding(const float *a, const float *b, float* out);
	;
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = out


.code
embedded_rounding PROC public

	vmovups zmm2, [rcx]
	vmovups zmm4, [rdx]

	mov eax, 0ffffh
	kmovw k6, eax

	vaddps zmm7 {k6}, zmm2, zmm4 {ru-sae}

	vmovups [r8], zmm7
	vzeroupper
	ret
embedded_rounding ENDP
end