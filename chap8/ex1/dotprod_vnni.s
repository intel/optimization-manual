#
# Copyright (C) 2021 by Intel Corporation
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

	.globl _dotprod_vnni_4x64x64
	.globl dotprod_vnni_4x64x64

	# void dotprod_vnni_4x64x64(uint8_t *lhs, int8_t *rhs, int32_t *out);
	# On entry:
	#     rdi = lhs
	#     rsi = rhs
	#     rdx = out

	.text
_dotprod_vnni_4x64x64:
dotprod_vnni_4x64x64:

	vpxord zmm0, zmm0, zmm0
	vpxord zmm6, zmm6, zmm6 
	vpxord zmm12, zmm12, zmm12
	vpxord zmm18, zmm18, zmm18
	vpxord zmm1, zmm1, zmm1
	vpxord zmm7, zmm7, zmm7
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

	xor rcx, rcx
inner:
	
	// inner loop of unrolled matrix multiply
	vpbroadcastd zmm24, [rdi]               # vpbroadcastd zmm24, signal
	vpbroadcastd zmm25, [rdi + 64]          # vpbroadcastd zmm25, signal + 64
	vpbroadcastd zmm26, [rdi + 128]         # vpbroadcastd zmm26, signal + 128
	vpbroadcastd zmm27, [rdi + 192]         # vpbroadcastd zmm27, signal + 192
	
	vmovups zmm28, [rsi]                    # vmovups zmm28, weight
	vmovups zmm29, [rsi + 64]               # vmovups zmm29, weight + 64
	vmovups zmm30, [rsi + 128]              # vmovups zmm30, weight + 128
	vmovups zmm31, [rsi + 192]              # vmovups zmm31, weight + 192
	vpdpbusd zmm0 , zmm24, zmm28
	vpdpbusd zmm6 , zmm24, zmm29
	vpdpbusd zmm12, zmm24, zmm30
	vpdpbusd zmm18, zmm24, zmm31
	vpdpbusd zmm1 , zmm25, zmm28
	vpdpbusd zmm7 , zmm25, zmm29
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

	add rsi, 256
	add rdi, 4	
	add rcx, 1
	cmp rcx, 16
	jl inner

	vmovupd [rdx], zmm0
	vmovupd [rdx + 64], zmm6
	vmovupd [rdx + 128], zmm12
	vmovupd [rdx + 192], zmm18
	vmovupd [rdx + 256], zmm1
	vmovupd [rdx + 320], zmm7
	vmovupd [rdx + 384], zmm13
	vmovupd [rdx + 448], zmm19
	vmovupd [rdx + 512], zmm2
	vmovupd [rdx + 576], zmm8
	vmovupd [rdx + 640], zmm14
	vmovupd [rdx + 704], zmm20
	vmovupd [rdx + 768], zmm3
	vmovupd [rdx + 832], zmm9
	vmovupd [rdx + 896], zmm15
	vmovupd [rdx + 960], zmm21

	vzeroupper
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
