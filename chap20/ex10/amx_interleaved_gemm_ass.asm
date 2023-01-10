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

        ;.intel_syntax noprefix

        ;.globl _amx_interleaved_gemm_ass
        ;.globl amx_interleaved_gemm_ass

        ; void amx_interleaved_gemm_ass(int32_t *c, const int8_t *a, const int8_t *b,
        ;                               const tc* config);
        ; On entry:
        ;     rcx = c
        ;     rdx = a
        ;     r8 = b
        ;     r9 = config
        ;
        ;  - the dimensions of a are expected to be 32x128 bytes
        ;  - the dimensions of b are expected to be 128x32 bytes
        ;  - the dimensions of c are expected to be 32x32  dwords

        ;.text

;
.code
amx_interleaved_gemm_ass PROC public
        ldtilecfg [r9]    ; ldtilecfg tc       	;  Load tile config
        mov rax, rdx        ; mov rax, A_mem    ;  Initialize register for A
        ;mov r8, r8        ; mov r8, B_mem      ;  Initialize register for B
        mov r10, rcx       ; mov r10, C_mem     ;  Initialize register for C

        mov r11, 128                            ;  Initialize register for strides
        tileloadd tmm6, [r8 + r11*1]            ;  Load B for n_acc = 0, k_acc = 0
        tileloadd tmm4, [rax + r11*1]           ;  Load A for m_acc = 0, k_acc = 0
        tilezero tmm0                           ;  Zero accumulator tile
        tdpbssd tmm0, tmm4, tmm6                ;  Multiply-add tmm0 += tmm4 * tmm6
        tileloadd tmm5, [rax + r11*1 + 2048]    ;  Load A for m_acc = 1, k_acc = 0
        tilezero tmm1                           ;  Zero accumulator tile
        tdpbssd tmm1, tmm5, tmm6                ;  Multiply-add tmm1 += tmm5 * tmm6
        tileloadd tmm6, [r8 + r11*1 + 64 ]      ;  Load B for n_acc = 1, k_acc = 0
        tilezero tmm2                           ;  Zero accumulator tile
        tdpbssd tmm2, tmm4, tmm6                ;  Multiply-add tmm2 += tmm4 * tmm6
        tilezero tmm3                           ;  Zero accumulator tile
        tdpbssd tmm3, tmm5, tmm6                ;  Multiply-add tmm3 += tmm5 * tmm6
        tileloadd tmm6, [r8 + r11*1 + 2048]     ;  Load B for n_acc = 0, k_acc = 1
        tileloadd tmm4, [rax + r11*1 + 64]      ;  Load A for m_acc = 0, k_acc = 1
        tdpbssd tmm0, tmm4, tmm6                ;  Multiply-add tmm0 += tmm4 * tmm6
        tilestored [r10 + r11*1], tmm0          ;  Store C for m_acc = 0, n_acc = 0
        tileloadd tmm5, [rax + r11*1 + 2112]    ;  Load A for m_acc = 1, k_acc = 1
        tdpbssd tmm1, tmm5, tmm6                ;  Multiply-add tmm1 += tmm5 * tmm6
        tilestored [r10 + r11*1 + 2048], tmm1   ;  Store C for m_acc = 1, n_acc = 0
        tileloadd tmm6, [r8 + r11*1 + 2112]     ;  Load B for n_acc = 1, k_acc = 1
        tdpbssd tmm2, tmm4, tmm6                ;  Multiply-add tmm2 += tmm4 * tmm6
        tilestored [r10 + r11*1 + 64], tmm2     ;  Store C for m_acc = 0, n_acc = 1
        tdpbssd tmm3, tmm5, tmm6                ;  Multiply-add tmm3 += tmm5 * tmm6
        tilestored [r10 + r11*1 + 2112], tmm3   ;  Store C for m_acc = 1, n_acc = 1

        ret

amx_interleaved_gemm_ass ENDP
end
