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

;	.globl no_unroll_reduce

	; float no_unroll_reduce(float *a, uint32_t len)
	; On entry:
	;     rcx = a
	;     edx = len
	;     xmm0 = retval


.code
no_unroll_reduce PROC public

	push rbx

	mov eax, edx
	mov rbx, rcx
	vmovups ymm0, ymmword ptr [rbx]
	sub eax, 8
loop_start:
	add rbx, 32
	vaddps ymm0, ymm0, ymmword ptr [rbx]
	sub eax, 8
	jnz loop_start

	vextractf128 xmm1, ymm0, 1
	vaddps xmm0, xmm0, xmm1
	vpermilps xmm1, xmm0, 0eh
	vaddps xmm0, xmm0, xmm1
	vpermilps xmm1, xmm0, 1
	vaddss xmm0, xmm0, xmm1

	; The following instruction is not needed as xmm0 already
	; holds the return value.

	; movss result, xmm0

	pop rbx

	vzeroupper
	ret
no_unroll_reduce ENDP
end