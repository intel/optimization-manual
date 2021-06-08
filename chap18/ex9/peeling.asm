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

;	.globl peel

	; void peel(float *out, const float *in, uint64_t width, float add_value, float alfa);
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = width
	;     xmm3 = add_value
	;     [rsp+48] = alfa

.data
indices DD 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

.code
peel PROC public

	push rbx

	mov rax, rdx                          ; mov rax, pImage ( Input )
	mov rbx, rcx                          ; mov rbx, pOutImage ( Output )
	mov r11, r8                          ; mov r11, len
	                                      ; movss xmm3, addValue
	vpbroadcastd zmm3, xmm3
	                                      ; movss xmm1, alfa
	vpbroadcastd zmm4, dword ptr[rsp+48]

	xor r10, r10
	xor r9, r9
	vmovups zmm0, indices           ; vmovups zmm0, [indices]
	vpbroadcastd zmm5, ecx
peeling:
	mov r8, rbx
	and r8, 03Fh
	jz endofpeeling                       ; nothing to peel
	neg r8
	add r8, 64                           ; 64 - X
	; now in r8 we have the number of bytes to the closest alignment
	mov r9, r8
	sar r9, 2                             ; now r9 contains number of elements in peeling
	vpbroadcastd zmm5, r9d
	vpcmpd k2, zmm0, zmm5, 1            ; compare lower to produce mask for peeling
	vmovups zmm1 {k2}{z}, zmmword ptr[rax]
	vfmadd213ps zmm1 {k2}{z}, zmm4, zmm3
	vmovups zmmword ptr[rbx] {k2}, zmm1              ; unaligned store
endofpeeling:
	sub r11, r9
	mov r10, r11
	sar r10, 4                             ; number of full iterations
	jz remainder                          ; no full iterations

mainloop:
	vmovups zmm1, zmmword ptr[rax + r8]
	vfmadd213ps zmm1, zmm4, zmm3
	vmovaps zmmword ptr[rbx + r8], zmm1             ; aligned store is safe here !!
	add r8, 40h
	sub r10, 1
	jne mainloop
remainder:
	; produce mask for remainder
	and r11, 0Fh                          ; number of elements in remainder
	jz endloop                                ; no elements in remainder
	vpbroadcastd zmm2, r11d
	vpcmpd k2, zmm0, zmm2, 1             ; compare lower
	vmovups zmm1 {k2}{z}, zmmword ptr[rax + r8]
	vfmadd213ps zmm1 {k2}{z}, zmm4, zmm3
	vmovaps zmmword ptr[rbx + r8] {k2}, zmm1        ; aligned
endloop:

	vzeroupper
	pop rbx

	ret
peel ENDP
end