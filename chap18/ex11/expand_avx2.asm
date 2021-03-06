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

;	.globl expand_avx2

	; void expand_avx2(int32_t *out, int32_t *in, size_t N);
	; On entry:
	;     rcx = a
	;     rdx = b
	;     r8 = N


_RDATA SEGMENT    READ ALIGN(32) 'DATA'

shuf2 DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 1, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 1, 0, 0, 0, 0, 0
	DD 0, 0, 1, 0, 0, 0, 0, 0
	DD 0, 1, 2, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 1, 0, 0, 0, 0
	DD 0, 0, 0, 1, 0, 0, 0, 0
	DD 0, 1, 0, 2, 0, 0, 0, 0
	DD 0, 0, 0, 1, 0, 0, 0, 0
	DD 0, 0, 1, 2, 0, 0, 0, 0
	DD 0, 0, 1, 2, 0, 0, 0, 0
	DD 0, 1, 2, 3, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 1, 0, 0, 0
	DD 0, 0, 0, 0, 1, 0, 0, 0
	DD 0, 1, 0, 0, 2, 0, 0, 0
	DD 0, 0, 0, 0, 1, 0, 0, 0
	DD 0, 0, 1, 0, 2, 0, 0, 0
	DD 0, 0, 1, 0, 2, 0, 0, 0
	DD 0, 1, 2, 0, 3, 0, 0, 0
	DD 0, 0, 0, 0, 1, 0, 0, 0
	DD 0, 0, 0, 1, 2, 0, 0, 0
	DD 0, 0, 0, 1, 2, 0, 0, 0
	DD 0, 1, 0, 2, 3, 0, 0, 0
	DD 0, 0, 0, 1, 2, 0, 0, 0
	DD 0, 0, 1, 2, 3, 0, 0, 0
	DD 0, 0, 1, 2, 3, 0, 0, 0
	DD 0, 1, 2, 3, 4, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 1, 0, 0
	DD 0, 0, 0, 0, 0, 1, 0, 0
	DD 0, 1, 0, 0, 0, 2, 0, 0
	DD 0, 0, 0, 0, 0, 1, 0, 0
	DD 0, 0, 1, 0, 0, 2, 0, 0
	DD 0, 0, 1, 0, 0, 2, 0, 0
	DD 0, 1, 2, 0, 0, 3, 0, 0
	DD 0, 0, 0, 0, 0, 1, 0, 0
	DD 0, 0, 0, 1, 0, 2, 0, 0
	DD 0, 0, 0, 1, 0, 2, 0, 0
	DD 0, 1, 0, 2, 0, 3, 0, 0
	DD 0, 0, 0, 1, 0, 2, 0, 0
	DD 0, 0, 1, 2, 0, 3, 0, 0
	DD 0, 0, 1, 2, 0, 3, 0, 0
	DD 0, 1, 2, 3, 0, 4, 0, 0
	DD 0, 0, 0, 0, 0, 1, 0, 0
	DD 0, 0, 0, 0, 1, 2, 0, 0
	DD 0, 0, 0, 0, 1, 2, 0, 0
	DD 0, 1, 0, 0, 2, 3, 0, 0
	DD 0, 0, 0, 0, 1, 2, 0, 0
	DD 0, 0, 1, 0, 2, 3, 0, 0
	DD 0, 0, 1, 0, 2, 3, 0, 0
	DD 0, 1, 2, 0, 3, 4, 0, 0
	DD 0, 0, 0, 0, 1, 2, 0, 0
	DD 0, 0, 0, 1, 2, 3, 0, 0
	DD 0, 0, 0, 1, 2, 3, 0, 0
	DD 0, 1, 0, 2, 3, 4, 0, 0
	DD 0, 0, 0, 1, 2, 3, 0, 0
	DD 0, 0, 1, 2, 3, 4, 0, 0
	DD 0, 0, 1, 2, 3, 4, 0, 0
	DD 0, 1, 2, 3, 4, 5, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 1, 0
	DD 0, 0, 0, 0, 0, 0, 1, 0
	DD 0, 1, 0, 0, 0, 0, 2, 0
	DD 0, 0, 0, 0, 0, 0, 1, 0
	DD 0, 0, 1, 0, 0, 0, 2, 0
	DD 0, 0, 1, 0, 0, 0, 2, 0
	DD 0, 1, 2, 0, 0, 0, 3, 0
	DD 0, 0, 0, 0, 0, 0, 1, 0
	DD 0, 0, 0, 1, 0, 0, 2, 0
	DD 0, 0, 0, 1, 0, 0, 2, 0
	DD 0, 1, 0, 2, 0, 0, 3, 0
	DD 0, 0, 0, 1, 0, 0, 2, 0
	DD 0, 0, 1, 2, 0, 0, 3, 0
	DD 0, 0, 1, 2, 0, 0, 3, 0
	DD 0, 1, 2, 3, 0, 0, 4, 0
	DD 0, 0, 0, 0, 0, 0, 1, 0
	DD 0, 0, 0, 0, 1, 0, 2, 0
	DD 0, 0, 0, 0, 1, 0, 2, 0
	DD 0, 1, 0, 0, 2, 0, 3, 0
	DD 0, 0, 0, 0, 1, 0, 2, 0
	DD 0, 0, 1, 0, 2, 0, 3, 0
	DD 0, 0, 1, 0, 2, 0, 3, 0
	DD 0, 1, 2, 0, 3, 0, 4, 0
	DD 0, 0, 0, 0, 1, 0, 2, 0
	DD 0, 0, 0, 1, 2, 0, 3, 0
	DD 0, 0, 0, 1, 2, 0, 3, 0
	DD 0, 1, 0, 2, 3, 0, 4, 0
	DD 0, 0, 0, 1, 2, 0, 3, 0
	DD 0, 0, 1, 2, 3, 0, 4, 0
	DD 0, 0, 1, 2, 3, 0, 4, 0
	DD 0, 1, 2, 3, 4, 0, 5, 0
	DD 0, 0, 0, 0, 0, 0, 1, 0
	DD 0, 0, 0, 0, 0, 1, 2, 0
	DD 0, 0, 0, 0, 0, 1, 2, 0
	DD 0, 1, 0, 0, 0, 2, 3, 0
	DD 0, 0, 0, 0, 0, 1, 2, 0
	DD 0, 0, 1, 0, 0, 2, 3, 0
	DD 0, 0, 1, 0, 0, 2, 3, 0
	DD 0, 1, 2, 0, 0, 3, 4, 0
	DD 0, 0, 0, 0, 0, 1, 2, 0
	DD 0, 0, 0, 1, 0, 2, 3, 0
	DD 0, 0, 0, 1, 0, 2, 3, 0
	DD 0, 1, 0, 2, 0, 3, 4, 0
	DD 0, 0, 0, 1, 0, 2, 3, 0
	DD 0, 0, 1, 2, 0, 3, 4, 0
	DD 0, 0, 1, 2, 0, 3, 4, 0
	DD 0, 1, 2, 3, 0, 4, 5, 0
	DD 0, 0, 0, 0, 0, 1, 2, 0
	DD 0, 0, 0, 0, 1, 2, 3, 0
	DD 0, 0, 0, 0, 1, 2, 3, 0
	DD 0, 1, 0, 0, 2, 3, 4, 0
	DD 0, 0, 0, 0, 1, 2, 3, 0
	DD 0, 0, 1, 0, 2, 3, 4, 0
	DD 0, 0, 1, 0, 2, 3, 4, 0
	DD 0, 1, 2, 0, 3, 4, 5, 0
	DD 0, 0, 0, 0, 1, 2, 3, 0
	DD 0, 0, 0, 1, 2, 3, 4, 0
	DD 0, 0, 0, 1, 2, 3, 4, 0
	DD 0, 1, 0, 2, 3, 4, 5, 0
	DD 0, 0, 0, 1, 2, 3, 4, 0
	DD 0, 0, 1, 2, 3, 4, 5, 0
	DD 0, 0, 1, 2, 3, 4, 5, 0
	DD 0, 1, 2, 3, 4, 5, 6, 0
	DD 0, 0, 0, 0, 0, 0, 0, 0
	DD 0, 0, 0, 0, 0, 0, 0, 1
	DD 0, 0, 0, 0, 0, 0, 0, 1
	DD 0, 1, 0, 0, 0, 0, 0, 2
	DD 0, 0, 0, 0, 0, 0, 0, 1
	DD 0, 0, 1, 0, 0, 0, 0, 2
	DD 0, 0, 1, 0, 0, 0, 0, 2
	DD 0, 1, 2, 0, 0, 0, 0, 3
	DD 0, 0, 0, 0, 0, 0, 0, 1
	DD 0, 0, 0, 1, 0, 0, 0, 2
	DD 0, 0, 0, 1, 0, 0, 0, 2
	DD 0, 1, 0, 2, 0, 0, 0, 3
	DD 0, 0, 0, 1, 0, 0, 0, 2
	DD 0, 0, 1, 2, 0, 0, 0, 3
	DD 0, 0, 1, 2, 0, 0, 0, 3
	DD 0, 1, 2, 3, 0, 0, 0, 4
	DD 0, 0, 0, 0, 0, 0, 0, 1
	DD 0, 0, 0, 0, 1, 0, 0, 2
	DD 0, 0, 0, 0, 1, 0, 0, 2
	DD 0, 1, 0, 0, 2, 0, 0, 3
	DD 0, 0, 0, 0, 1, 0, 0, 2
	DD 0, 0, 1, 0, 2, 0, 0, 3
	DD 0, 0, 1, 0, 2, 0, 0, 3
	DD 0, 1, 2, 0, 3, 0, 0, 4
	DD 0, 0, 0, 0, 1, 0, 0, 2
	DD 0, 0, 0, 1, 2, 0, 0, 3
	DD 0, 0, 0, 1, 2, 0, 0, 3
	DD 0, 1, 0, 2, 3, 0, 0, 4
	DD 0, 0, 0, 1, 2, 0, 0, 3
	DD 0, 0, 1, 2, 3, 0, 0, 4
	DD 0, 0, 1, 2, 3, 0, 0, 4
	DD 0, 1, 2, 3, 4, 0, 0, 5
	DD 0, 0, 0, 0, 0, 0, 0, 1
	DD 0, 0, 0, 0, 0, 1, 0, 2
	DD 0, 0, 0, 0, 0, 1, 0, 2
	DD 0, 1, 0, 0, 0, 2, 0, 3
	DD 0, 0, 0, 0, 0, 1, 0, 2
	DD 0, 0, 1, 0, 0, 2, 0, 3
	DD 0, 0, 1, 0, 0, 2, 0, 3
	DD 0, 1, 2, 0, 0, 3, 0, 4
	DD 0, 0, 0, 0, 0, 1, 0, 2
	DD 0, 0, 0, 1, 0, 2, 0, 3
	DD 0, 0, 0, 1, 0, 2, 0, 3
	DD 0, 1, 0, 2, 0, 3, 0, 4
	DD 0, 0, 0, 1, 0, 2, 0, 3
	DD 0, 0, 1, 2, 0, 3, 0, 4
	DD 0, 0, 1, 2, 0, 3, 0, 4
	DD 0, 1, 2, 3, 0, 4, 0, 5
	DD 0, 0, 0, 0, 0, 1, 0, 2
	DD 0, 0, 0, 0, 1, 2, 0, 3
	DD 0, 0, 0, 0, 1, 2, 0, 3
	DD 0, 1, 0, 0, 2, 3, 0, 4
	DD 0, 0, 0, 0, 1, 2, 0, 3
	DD 0, 0, 1, 0, 2, 3, 0, 4
	DD 0, 0, 1, 0, 2, 3, 0, 4
	DD 0, 1, 2, 0, 3, 4, 0, 5
	DD 0, 0, 0, 0, 1, 2, 0, 3
	DD 0, 0, 0, 1, 2, 3, 0, 4
	DD 0, 0, 0, 1, 2, 3, 0, 4
	DD 0, 1, 0, 2, 3, 4, 0, 5
	DD 0, 0, 0, 1, 2, 3, 0, 4
	DD 0, 0, 1, 2, 3, 4, 0, 5
	DD 0, 0, 1, 2, 3, 4, 0, 5
	DD 0, 1, 2, 3, 4, 5, 0, 6
	DD 0, 0, 0, 0, 0, 0, 0, 1
	DD 0, 0, 0, 0, 0, 0, 1, 2
	DD 0, 0, 0, 0, 0, 0, 1, 2
	DD 0, 1, 0, 0, 0, 0, 2, 3
	DD 0, 0, 0, 0, 0, 0, 1, 2
	DD 0, 0, 1, 0, 0, 0, 2, 3
	DD 0, 0, 1, 0, 0, 0, 2, 3
	DD 0, 1, 2, 0, 0, 0, 3, 4
	DD 0, 0, 0, 0, 0, 0, 1, 2
	DD 0, 0, 0, 1, 0, 0, 2, 3
	DD 0, 0, 0, 1, 0, 0, 2, 3
	DD 0, 1, 0, 2, 0, 0, 3, 4
	DD 0, 0, 0, 1, 0, 0, 2, 3
	DD 0, 0, 1, 2, 0, 0, 3, 4
	DD 0, 0, 1, 2, 0, 0, 3, 4
	DD 0, 1, 2, 3, 0, 0, 4, 5
	DD 0, 0, 0, 0, 0, 0, 1, 2
	DD 0, 0, 0, 0, 1, 0, 2, 3
	DD 0, 0, 0, 0, 1, 0, 2, 3
	DD 0, 1, 0, 0, 2, 0, 3, 4
	DD 0, 0, 0, 0, 1, 0, 2, 3
	DD 0, 0, 1, 0, 2, 0, 3, 4
	DD 0, 0, 1, 0, 2, 0, 3, 4
	DD 0, 1, 2, 0, 3, 0, 4, 5
	DD 0, 0, 0, 0, 1, 0, 2, 3
	DD 0, 0, 0, 1, 2, 0, 3, 4
	DD 0, 0, 0, 1, 2, 0, 3, 4
	DD 0, 1, 0, 2, 3, 0, 4, 5
	DD 0, 0, 0, 1, 2, 0, 3, 4
	DD 0, 0, 1, 2, 3, 0, 4, 5
	DD 0, 0, 1, 2, 3, 0, 4, 5
	DD 0, 1, 2, 3, 4, 0, 5, 6
	DD 0, 0, 0, 0, 0, 0, 1, 2
	DD 0, 0, 0, 0, 0, 1, 2, 3
	DD 0, 0, 0, 0, 0, 1, 2, 3
	DD 0, 1, 0, 0, 0, 2, 3, 4
	DD 0, 0, 0, 0, 0, 1, 2, 3
	DD 0, 0, 1, 0, 0, 2, 3, 4
	DD 0, 0, 1, 0, 0, 2, 3, 4
	DD 0, 1, 2, 0, 0, 3, 4, 5
	DD 0, 0, 0, 0, 0, 1, 2, 3
	DD 0, 0, 0, 1, 0, 2, 3, 4
	DD 0, 0, 0, 1, 0, 2, 3, 4
	DD 0, 1, 0, 2, 0, 3, 4, 5
	DD 0, 0, 0, 1, 0, 2, 3, 4
	DD 0, 0, 1, 2, 0, 3, 4, 5
	DD 0, 0, 1, 2, 0, 3, 4, 5
	DD 0, 1, 2, 3, 0, 4, 5, 6
	DD 0, 0, 0, 0, 0, 1, 2, 3
	DD 0, 0, 0, 0, 1, 2, 3, 4
	DD 0, 0, 0, 0, 1, 2, 3, 4
	DD 0, 1, 0, 0, 2, 3, 4, 5
	DD 0, 0, 0, 0, 1, 2, 3, 4
	DD 0, 0, 1, 0, 2, 3, 4, 5
	DD 0, 0, 1, 0, 2, 3, 4, 5
	DD 0, 1, 2, 0, 3, 4, 5, 6
	DD 0, 0, 0, 0, 1, 2, 3, 4
	DD 0, 0, 0, 1, 2, 3, 4, 5
	DD 0, 0, 0, 1, 2, 3, 4, 5
	DD 0, 1, 0, 2, 3, 4, 5, 6
	DD 0, 0, 0, 1, 2, 3, 4, 5
	DD 0, 0, 1, 2, 3, 4, 5, 6
	DD 0, 0, 1, 2, 3, 4, 5, 6
	DD 0, 1, 2, 3, 4, 5, 6, 7

_RDATA ENDS

.code
expand_avx2 PROC public

	push r13
	push r14
	push r15

					; mov rdx, input
					; mov rcx, output
	mov r9, r8		; mov r9, len
	xor r8, r8
	xor r10, r10

	vpxor ymm0, ymm0, ymm0
	lea r14, shuf2		; mov r14, shuf2

mainloop:
	vmovdqa ymm1, ymmword ptr[rdx+r8*4]
	vpxor ymm4, ymm4, ymm4
	vpcmpgtd ymm2, ymm1, ymm0
	vmovdqu ymm1, ymmword ptr[rdx+r10*4]
	vmovmskps r13, ymm2
	shl r13, 5
	vmovdqa ymm3, ymmword ptr[r14+r13]
	vpermd ymm4, ymm3, ymm1
	popcnt r13, r13
	add r10, r13
	vmaskmovps [rcx+r8*4], ymm2, ymm4
	add r8, 8
	cmp r8, r9
	jne mainloop

	pop r15
	pop r14
	pop r13

	vzeroupper
	ret
expand_avx2 ENDP
end