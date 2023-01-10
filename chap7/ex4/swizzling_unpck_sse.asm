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

;    .globl swizzling_unpck_sse

    ; void swizzling_unpck_sse(Vertex_aos *in, Vertex_soa *out)
    ; On entry:
    ;     rcx = in
    ;     rdx = out


.code
swizzling_unpck_sse PROC public
    ; store non-volatile registers on stack
    push rbx

    mov rbx, rcx               ; mov rbx, aos*
    ;out is already in rdx 

    movdqa xmm1, [rbx + 0*16]    ; w0 z0 y0 x0
    movdqa xmm2, [rbx + 1*16]    ; w1 z1 y1 x1
    movdqa xmm3, [rbx + 2*16]    ; w2 z2 y2 x2
    movdqa xmm4, [rbx + 3*16]    ; w3 z3 y3 x3
    movdqa xmm5, xmm1
    punpckldq xmm1, xmm2         ; y1 y0 x1 x0
    punpckhdq xmm5, xmm2         ; w1 w0 z1 z0
    movdqa xmm2, xmm3
    punpckldq xmm3, xmm4         ; y3 y2 x3 x2
    punpckhdq xmm2, xmm4         ; w3 w2 z3 z2
    movdqa xmm4, xmm1
    punpcklqdq xmm1, xmm3        ; x3 x2 x1 x0
    punpckhqdq xmm4, xmm3        ; y3 y2 y1 y0
    movdqa xmm3, xmm5
    punpcklqdq xmm5, xmm2        ; z3 z2 z1 z0
    punpckhqdq xmm3, xmm2        ; w3 w2 w1 w0
    movdqa [rdx+0*16], xmm1      ; x3 x2 x1 x0
    movdqa [rdx+1*16], xmm4      ; y3 y2 y1 y0
    movdqa [rdx+2*16], xmm5      ; z3 z2 z1 z0
    movdqa [rdx+3*16], xmm3      ; w3 w2 w1 w0

    pop rbx
    ret

swizzling_unpck_sse ENDP
end
