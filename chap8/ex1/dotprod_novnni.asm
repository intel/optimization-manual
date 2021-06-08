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

;	.globl dotprod_novnni_4x64x64

	; void dotprod_novnni_4x64x64(uint8_t *lhs, int8_t *rhs, int32_t *out);
	; On entry:
	;     rcx = lhs
	;     rdx = rhs
	;     r8 = out

	.data
	ALIGN 4
onew DW 1,1

.code
dotprod_novnni_4x64x64 PROC public

	sub rsp, 104
	vmovaps xmmword ptr[rsp], xmm8
	vmovaps xmmword ptr[rsp+16], xmm9
	vmovaps xmmword ptr[rsp+32], xmm12
	vmovaps xmmword ptr[rsp+48], xmm13
	vmovaps xmmword ptr[rsp+64], xmm14
	vmovaps xmmword ptr[rsp+80], xmm15

	vpxord zmm0, zmm0, zmm0
	vpxord zmm4, zmm4, zmm4
	vpxord zmm12, zmm12, zmm12
	vpxord zmm18, zmm18, zmm18
	vpxord zmm1, zmm1, zmm1
	vpxord zmm5, zmm5, zmm5
	vpxord zmm13, zmm13, zmm13
	vpxord zmm19, zmm19, zmm19
	vpxord zmm2, zmm2, zmm2
	vpxord zmm8, zmm8, zmm8
	vpxord zmm14, zmm14, zmm14
	vpxord zmm20, zmm20, zmm20
	vpxord zmm3, zmm3, zmm3
	vpxord zmm9, zmm9, zmm9
	vpxord zmm15, zmm15, zmm15
	vpxord zmm21, zmm21, zmm21

	xor r10, r10
	mov eax, 01h
inner:
;	// inner loop of unrolled dot product
	vpbroadcastd zmm31, dword ptr onew ; vpbroadcastd zmm31, dword ptr onew
	vpbroadcastd zmm24, dword ptr[rcx]               ; vpbroadcastd zmm24, signal
	vmovups zmm25, [rdx]                    ; vmovups zmm25, weight
	vmovups zmm26, [rdx + 64]               ; vmovups zmm26, weight + 64
	vmovups zmm27, [rdx + 128]              ; vmovups zmm27, weight + 128
	vmovups zmm28, [rdx + 192]              ; vmovups zmm28, weight + 192
	vpmaddubsw zmm29, zmm24, zmm25
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm0 , zmm0 , zmm29
	vpmaddubsw zmm30, zmm24, zmm26
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm4 , zmm4 , zmm30
	vpmaddubsw zmm29, zmm24, zmm27
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm12, zmm12, zmm29
	vpmaddubsw zmm30, zmm24, zmm28
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm18, zmm18, zmm30
	vpbroadcastd zmm24, dword ptr[rcx + 64]         ; vpbroadcastd zmm24, signal + 64
	vpmaddubsw zmm29, zmm24, zmm25
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm1 , zmm1 , zmm29
	vpmaddubsw zmm30, zmm24, zmm26
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm5 , zmm5 , zmm30
	vpmaddubsw zmm29, zmm24, zmm27
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm13, zmm13, zmm29
	vpmaddubsw zmm30, zmm24, zmm28
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm19, zmm19, zmm30
	vpbroadcastd zmm24,dword ptr [rcx + 128]        ; vpbroadcastd zmm24, signal + 128
	vpmaddubsw zmm29, zmm24, zmm25
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm2 , zmm2 , zmm29
	vpmaddubsw zmm30, zmm24, zmm26
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm8 , zmm8 , zmm30
	vpmaddubsw zmm29, zmm24, zmm27
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm14, zmm14, zmm29
	vpmaddubsw zmm30, zmm24, zmm28
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm20, zmm20, zmm30
	vpbroadcastd zmm24, dword ptr[rcx + 192]        ; vpbroadcastd zmm24, signal + 192
	vpmaddubsw zmm29, zmm24, zmm25
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm3 , zmm3 , zmm29
	vpmaddubsw zmm30, zmm24, zmm26
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm9 , zmm9 , zmm30
	vpmaddubsw zmm29, zmm24, zmm27
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm15, zmm15, zmm29
	vpmaddubsw zmm30, zmm24, zmm28
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm21, zmm21, zmm30

	add rdx, 256
	add rcx, 4
	add r10, 1
	cmp r10, 16
	jl inner

	vmovupd [r8], zmm0
	vmovupd [r8 + 64], zmm4
	vmovupd [r8 + 128], zmm12
	vmovupd [r8 + 192], zmm18
	vmovupd [r8 + 256], zmm1
	vmovupd [r8 + 320], zmm5
	vmovupd [r8 + 384], zmm13
	vmovupd [r8 + 448], zmm19
	vmovupd [r8 + 512], zmm2
	vmovupd [r8 + 576], zmm8
	vmovupd [r8 + 640], zmm14
	vmovupd [r8 + 704], zmm20
	vmovupd [r8 + 768], zmm3
	vmovupd [r8 + 832], zmm9
	vmovupd [r8 + 896], zmm15
	vmovupd [r8 + 960], zmm21

	vzeroupper
	vmovaps xmm8, xmmword ptr[rsp]
	vmovaps xmm9, xmmword ptr[rsp+16]
	vmovaps xmm12, xmmword ptr[rsp+32]
	vmovaps xmm13, xmmword ptr[rsp+48]
	vmovaps xmm14, xmmword ptr[rsp+64]
	vmovaps xmm15, xmmword ptr[rsp+80]
	add rsp, 104

	ret
dotprod_novnni_4x64x64 ENDP
end