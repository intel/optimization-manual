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

;    .globl swizzling_sse

    ; void swizzling_sse(Vertex_aos *in, Vertex_soa *out)
    ; On entry:
    ;     rcx = in
    ;     rdx = out


.code
swizzling_sse PROC public
    ; store non-volatile registers on stack
    push rbx
    sub rsp, 32
    vmovaps xmmword ptr[rsp], xmm6
    vmovaps  xmmword ptr[rsp+16], xmm7

    mov rbx, rcx               ; mov rbx, aos*
    ;out is already in rdx

    movaps xmm1, [rbx]         ; w0 z0 y0 x0
    movaps xmm2, [rbx+16]      ; w1 z1 y1 x1
    movaps xmm3, [rbx+32]      ; w2 z2 y2 x2
    movaps xmm4, [rbx+48]      ; w3 z3 y3 x3
    movaps xmm7, xmm4          ; xmm7= w3 z3 y3 x3
    movhlps xmm7, xmm3         ; xmm7= w3 z3 w2 z2
    movaps xmm6, xmm2          ; xmm6= w1 z1 y1 x1
    movlhps xmm3, xmm4         ; xmm3= y3 x3 y2 x2
    movhlps xmm2, xmm1         ; xmm2= w1 z1 w0 z0
    movlhps xmm1, xmm6         ; xmm1= y1 x1 y0 x0
    movaps xmm6, xmm2          ; xmm6= w1 z1 w0 z0
    movaps xmm5, xmm1          ; xmm5= y1 x1 y0 x0
    shufps xmm2, xmm7, 0DDh    ; xmm2= w3 w2 w1 w0 => W
    shufps xmm1, xmm3, 088h    ; xmm1= x3 x2 x1 x0 => X
    shufps xmm5, xmm3, 0DDh    ; xmm5= y3 y2 y1 y0 => Y
    shufps xmm6, xmm7, 088h    ; xmm6= z3 z2 z1 z0 => Z
    movaps [rdx], xmm1         ; store X
    movaps [rdx+16], xmm5      ; store Y
    movaps [rdx+32], xmm6      ; store Z
    movaps [rdx+48], xmm2      ; store W

    vmovaps xmm6, xmmword ptr[rsp]
    vmovaps xmm7, xmmword ptr[rsp+16]
    add rsp, 32
    pop rbx
    ret

swizzling_sse ENDP
end
