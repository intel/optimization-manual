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

;	.globl avx_compress

	; uint64_t avx_compress(uint32_t *out, const uint32_t *in, uint64_t len)
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = len

	; On exit
	;     rax = out_len

	.data
	ALIGN 16

shuffle_LUT DD 80808080, 80808080h, 80808080h, 80808080h
			DD 03020100h, 80808080h, 80808080h, 80808080h
			DD 07060504h, 80808080h, 80808080h, 80808080h
			DD 03020100h, 07060504h, 80808080h, 80808080h
			DD 0b0A0908h, 80808080h, 80808080h, 80808080h
			DD 03020100h, 0b0A0908h, 80808080h, 80808080h
			DD 07060504h, 0b0A0908h, 80808080h, 80808080h
			DD 03020100h, 07060504h, 0b0A0908h, 80808080h
			DD 0F0E0D0Ch, 80808080h, 80808080h, 80808080h
			DD 03020100h, 0F0E0D0Ch, 80808080h, 80808080h
			DD 07060504h, 0F0E0D0Ch, 80808080h, 80808080h
			DD 03020100h, 07060504h, 0F0E0D0Ch, 80808080h
			DD 0b0A0908h, 0F0E0D0Ch, 80808080h, 80808080h
			DD 03020100h, 0b0A0908h, 0F0E0D0Ch, 80808080h
			DD 07060504h, 0b0A0908h, 0F0E0D0Ch, 80808080h
			DD 03020100h, 07060504h, 0b0A0908h, 0F0E0D0Ch

write_mask	DD 80000000h, 80000000h, 80000000h, 80000000h
			DD 00000000h, 00000000h, 00000000h, 00000000h

.code
avx_compress PROC public

	push r13
	push r14
	push r15
	                                   ; mov rdx, source
	                                   ; mov rcx, dest
	mov r9, r8                         ; mov r9, len
	lea r14, shuffle_LUT          ; mov r14, shuffle_LUT
	lea r15, write_mask           ; mov r15, write_mask

	xor r8, r8
	xor r11, r11
	vpxor xmm0, xmm0, xmm0

mainloop:
	vmovdqa xmm1, xmmword ptr[rdx+r8*4]
	vpcmpgtd xmm2, xmm1, xmm0
	mov r10, 4
	vmovmskps r13, xmm2
	shl r13, 4
	vmovdqu xmm3, xmmword ptr[r14+r13]
	vpshufb xmm2, xmm1, xmm3

	popcnt r13, r13
	sub r10, r13
	vmovdqu xmm3, xmmword ptr[r15+r10*4]
	vmaskmovps [rcx+r11*4], xmm3, xmm2
	add r11, r13
	add r8, 4
	cmp r8, r9
	jne mainloop

	vzeroupper

	pop r15
	pop r14
	pop r13

	mov rax, r11

	ret

avx_compress ENDP
end