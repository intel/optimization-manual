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

;	.globl dotprod_vnni_4x64x64

	; void dotprod_vnni_4x64x64(uint8_t *lhs, int8_t *rhs, int32_t *out);
	; On entry:
	;     rcx = lhs
	;     rdx = rhs
	;     r8 = out

.code
dotprod_vnni_4x64x64 PROC public
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
inner:

;	// inner loop of unrolled dot product
	vpbroadcastd zmm24, dword ptr[rcx]               ; vpbroadcastd zmm24, signal
	vpbroadcastd zmm25, dword ptr[rcx + 64]          ; vpbroadcastd zmm25, signal + 64
	vpbroadcastd zmm26, dword ptr[rcx + 128]         ; vpbroadcastd zmm26, signal + 128
	vpbroadcastd zmm27, dword ptr[rcx + 192]         ; vpbroadcastd zmm27, signal + 192

	vmovups zmm28, [rdx]                    ; vmovups zmm28, weight
	vmovups zmm29, [rdx + 64]               ; vmovups zmm29, weight + 64
	vmovups zmm30, [rdx + 128]              ; vmovups zmm30, weight + 128
	vmovups zmm31, [rdx + 192]              ; vmovups zmm31, weight + 192
	vpdpbusd zmm0 , zmm24, zmm28
	vpdpbusd zmm4 , zmm24, zmm29
	vpdpbusd zmm12, zmm24, zmm30
	vpdpbusd zmm18, zmm24, zmm31
	vpdpbusd zmm1 , zmm25, zmm28
	vpdpbusd zmm5 , zmm25, zmm29
	vpdpbusd zmm13, zmm25, zmm30
	vpdpbusd zmm19, zmm25, zmm31
	vpdpbusd zmm2 , zmm26, zmm28
	vpdpbusd zmm8 , zmm26, zmm29
	vpdpbusd zmm14, zmm26, zmm30
	vpdpbusd zmm20, zmm26, zmm31
	vpdpbusd zmm3 , zmm27, zmm28
	vpdpbusd zmm9 , zmm27, zmm29
	vpdpbusd zmm15, zmm27, zmm30
	vpdpbusd zmm21, zmm27, zmm31

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
dotprod_vnni_4x64x64 ENDP
end
