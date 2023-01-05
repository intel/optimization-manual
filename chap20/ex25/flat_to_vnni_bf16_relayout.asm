;
; Copyright (C) 2022 by Intel Corporation
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

M EQU 4
N EQU 96
K_PACK EQU 2
I_STRIDE EQU N * 2
O_STRIDE EQU N * 2 * K_PACK

	;.intel_syntax noprefix

	;.globl _flat_to_vnni_bf16_relayout
	;.globl flat_to_vnni_bf16_relayout

	; void flat_to_vnni_bf16_relayout(const bfloat_16 *input, bfloat_16 *output);
	; On entry:
	;     rcx = input
	;     rdx = output

	;.text

;

_RDATA SEGMENT    READ ALIGN(64) 'DATA'

perm_cnt1 DW 00h, 20h, 01h, 21h, 02h, 22h, 03h, 23h
DW 004h, 024h, 005h, 025h, 006h, 026h, 007h, 027h
DW 008h, 028h, 009h, 029h, 00ah, 02ah, 00bh, 02bh
DW 00ch, 02ch, 00dh, 02dh, 00eh, 02eh, 00fh, 02fh
perm_cnt2 DW 030h, 010h, 031h, 011h, 032h, 012h, 033h, 013h
DW 034h, 014h, 035h, 015h, 036h, 016h, 037h, 017h
DW 038h, 018h, 039h, 019h, 03ah, 01ah, 03bh, 01bh
DW 03ch, 01ch, 03dh, 01dh, 03eh, 01eh, 03fh, 01fh

_RDATA ENDS

.code
flat_to_vnni_bf16_relayout PROC public

	mov r8, rcx
	mov r9, rdx
	vmovdqa32 zmm30, zmmword ptr perm_cnt1
	vmovdqa32 zmm31, zmmword ptr perm_cnt2

	mov rdx, M / 2
L_M:
	mov rax, N / 32
L_N:
	vmovups zmm0, zmmword ptr [r8]
	vmovups zmm1, zmmword ptr [r8+I_STRIDE]

	vmovups zmm2, zmm0
	vpermt2w zmm2, zmm30, zmm1
	vpermt2w zmm1, zmm31, zmm0

	vmovups zmmword ptr [r9], zmm2
	vmovups zmmword ptr [r9+040h], zmm1

	add r9, 080h
	add r8, 040h
	dec rax
	jnz L_N
        add r9, (O_STRIDE - (N/32)*080h)
        add r8, (I_STRIDE*2 - (N/32)*040h)
	dec rdx
	jnz L_M

	vzeroupper
	ret

flat_to_vnni_bf16_relayout ENDP
end
