;
; Copyright (C) 2023 by Intel Corporation
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

	; .globl deswizzling_rgb_sse

	; void deswizzling_rgb_sse(Vertex_soa *in, Vertex_aos *out)
	; On entry:
	;	  rcx = in
	;	  rdx = out

.code
deswizzling_rgb_sse PROC public
	; store non-volatile registers on stack
	sub rsp, 40
	movaps xmmword ptr[rsp], xmm6
	movaps xmmword ptr[rsp+16], xmm7

	movdqa xmm0, [rcx]      ; load r4 r3 r2 r1 => xmm0
	movdqa xmm1, [rcx+16]   ; load g4 g3 g2 g1 => xmm1
	movdqa xmm2, [rcx+32]   ; load b4 b3 b2 b1 => xmm2
	movdqa xmm3, [rcx+48]   ; load a4 a3 a2 a1 => xmm3

	; Start deswizzling here
	movdqa xmm5, xmm0
	movdqa xmm7, xmm2
	punpckldq xmm0, xmm1	; g2 r2 g1 r1
	punpckldq xmm2, xmm3	; a2 b2 a1 b1
	movdqa xmm4, xmm0
	punpcklqdq xmm0, xmm2	; a1 b1 g1 r1 => v1
	punpckhqdq xmm4, xmm2	; a2 b2 g2 r2 => v2
	punpckhdq xmm5, xmm1	; g4 r4 g3 r3
	punpckhdq xmm7, xmm3	; a4 b4 a3 b3
	movdqa xmm6, xmm5
	punpcklqdq xmm5, xmm7	; a3 b3 g3 r3 => v3
	punpckhqdq xmm6, xmm7	; a4 b4 g4 r4 => v4
	movdqa [rdx], xmm0		; v1
	movdqa [rdx+16], xmm4	; v2
	movdqa [rdx+32], xmm5	; v3
	movdqa [rdx+48], xmm6	; v4

	movaps xmm6, xmmword ptr[rsp]
	movaps xmm7, xmmword ptr[rsp+16]
	add rsp, 40
	ret

deswizzling_rgb_sse ENDP
end
