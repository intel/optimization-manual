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


;	.globl saxpy_512

	; void saxpy_512(float* src, float *src2, size_t len, float *dst, float alpha);
	; On entry:
	;     rcx = src
	;     rdx = src2
	;     r8 = len (length in bytes of all three arrays)
	;     r9 = dst
	;     xmm0 = alpha



.code 
saxpy_512 PROC public
	push rbx

	mov rax, rcx 			; mov rax, src1
	mov rbx, rdx			; mov rbx, src2
					; mov r9, dst
					; mov r8, len
	xor rcx, rcx
	vbroadcastss zmm0, xmm0		; vbroadcastss zmm0, alpha
mainloop:
	vmovups zmm1, [rax]
	vfmadd213ps zmm1, zmm0, [rbx]
	vmovups [r9], zmm1
	vmovups zmm1, [rax+040h]
	vfmadd213ps zmm1, zmm0, [rbx+040h]
	vmovups [r9+040h], zmm1
	vmovups zmm1, [rax+080h]
	vfmadd213ps zmm1, zmm0, [rbx+080h]
	vmovups [r9+080h], zmm1
	vmovups zmm1, [rax+0C0h]
	vfmadd213ps zmm1, zmm0, [rbx+0C0h]
	vmovups [r9+0C0h], zmm1
	add rax, 256
	add rbx, 256
	add r9, 256
	add rcx, 64
	cmp rcx, r8
	jl mainloop

	pop rbx

	vzeroupper

	ret
saxpy_512 ENDP
end