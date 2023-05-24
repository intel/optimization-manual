#
# Copyright (C) 2023 by Intel Corporation
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

    .intel_syntax noprefix

    .globl _deswizzling_sse
    .globl deswizzling_sse

    # void deswizzling_sse(Vertex_soa *in, Vertex_aos *out)
    # On entry:
    #     rdi = in
    #     rsi = out

    .text

_deswizzling_sse:
deswizzling_sse:

    mov rcx, rdi
    mov rdx, rsi

    movaps xmm0, [rcx]          # x3 x2 x1 x0
    movaps xmm1, [rcx + 16]     # y3 y2 y1 y0
    movaps xmm2, [rcx + 32]     # z3 z2 z1 z0
    movaps xmm3, [rcx + 48]     # w3 w2 w1 w0
    movaps xmm5, xmm0
    movaps xmm7, xmm2
    unpcklps xmm0, xmm1         # y1 x1 y0 x0
    unpcklps xmm2, xmm3         # w1 z1 w0 z0
    movdqa xmm4, xmm0
    movlhps xmm0, xmm2          # w0 z0 y0 x0
    movhlps xmm2, xmm4          # w1 z1 y1 x1
    unpckhps xmm5, xmm1         # y3 x3 y2 x2
    unpckhps xmm7, xmm3         # w3 z3 w2 z2
    movdqa xmm6, xmm5
    movlhps xmm5, xmm7          # w2 z2 y2 x2
    movhlps xmm7, xmm6          # w3 z3 y3 x3
    movaps [rdx+0*16], xmm0     # w0 z0 y0 x0
    movaps [rdx+1*16], xmm2     # w1 z1 y1 x1
    movaps [rdx+2*16], xmm5     # w2 z2 y2 x2
    movaps [rdx+3*16], xmm7     # w3 z3 y3 x3

    ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
