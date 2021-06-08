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

;	.globl expand_avx512

	; void expand_avx512(int32_t *out, int32_t *in, size_t N);
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = N


.code
expand_avx512 PROC public

	push r12

					; mov rdx, input
					; mov rcx, output
	mov r9, r8		; mov r9, len
	xor r8, r8
	xor r10, r10

	vpxord zmm0, zmm0, zmm0
mainloop:
	vmovdqa32 zmm1, zmmword ptr[rdx+r8*4]
	vpcmpgtd k1, zmm1, zmm0
	vmovdqu32 zmm1, zmmword ptr[rdx+r10*4]
	vpexpandd zmm2 {k1}{z}, zmm1
	vmovdqu32 zmmword ptr[rcx+r8*4], zmm2
	add r8, 16
	kmovd r11d, k1
	popcnt r12, r11
	add r10, r12
	cmp r8, r9
	jne mainloop

	pop r12

	vzeroupper
	ret
expand_avx512 ENDP
end