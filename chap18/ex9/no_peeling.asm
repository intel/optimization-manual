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

;	.globl no_peeling

	; void no_peeling(float *out, const float *in, uint64_t width, float add_value, float alfa);
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = width
	;     xmm3 = add_value
	;     [rsp+48] = alfa


_RDATA SEGMENT    READ ALIGN(64) 'DATA'

indices DD 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

_RDATA ENDS

.code
no_peeling PROC public

	push rbx

	mov rbx, rcx               ; mov rbx, pOutImage ( Output )
	mov rax, rdx               ; mov rax, pImage ( Input )
	mov r11, r8                ; mov r11, len
	                           ; movss xmm0, addValue
	vpbroadcastd zmm3, xmm3
	                           ; movss xmm1, alfa
	vpbroadcastd zmm4, dword ptr[rsp+48]
	mov r8, r11
	sar r8, 4                 ; 16 elements per iteration, r8 - number of full iterations
	jz remainder               ; no full iterations
	xor r10, r10
	vmovups zmm5, indices
mainloop:
	vmovups zmm1, zmmword ptr[rax + r10]
	vfmadd213ps zmm1, zmm4, zmm3
	vmovups zmmword ptr[rbx + r10], zmm1
	add r10, 40h
	sub r8, 1
	jne mainloop
remainder:
	; produce mask for remainder
	and r11, 0Fh               ; number of elements in remainder
	jz endloop                     ; no elements in remainder
	vpbroadcastd zmm2, r11d
	vpcmpd k2, zmm5, zmm2, 1  ; compare lower
	vmovups zmm1 {k2}{z}, zmmword ptr[rax + r10]
	vfmadd213ps zmm1 {k2}{z}, zmm4, zmm3
	vmovups zmmword ptr[rbx + r10] {k2}, zmm1
endloop:

	pop rbx
	vzeroupper

	ret
no_peeling ENDP
end