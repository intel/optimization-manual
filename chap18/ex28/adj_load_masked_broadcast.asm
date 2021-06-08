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


;	.globl adj_load_masked_broadcast

	; void adj_load_masked_broadcast(int64_t len, const int32_t *indices,
	;                                const elem_struct_t *elems, double *out);
	;     rcx = len
	;     rdx = indices
	;     r8 = elems
	;     r9 = out


.code
adj_load_masked_broadcast PROC public

	mov eax, 0f0h
	kmovd k1, eax

						; rcx = len
	mov r10, r9		; r10 = out
	xor r9, r9

loop1:
	movsxd r11, DWORD PTR[rdx+r9*4]
	shl r11, 05h
	vmovupd ymm0, [r8+r11*1]
	movsxd r11, DWORD PTR [rdx+r9*4+04h]
	shl r11, 05h
	vbroadcastf64x4 zmm0{k1}, YMMWORD PTR [r8+r11*1]
	mov r11d, r9d
	shl r11d, 02h
	add r9, 02h
	movsxd r11, r11d
	vmovups [r10+r11*8], zmm0
	cmp r9, rcx
	jl loop1
	vzeroupper

	ret
adj_load_masked_broadcast ENDP
end