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

	.globl _dotprod_novnni_4x64x64
	.globl dotprod_novnni_4x64x64

	# void dotprod_novnni_4x64x64(uint8_t *lhs, int8_t *rhs, int32_t *out);
	# On entry:
	#     rdi = lhs
	#     rsi = rhs
	#     rdx = out

	.text
_dotprod_novnni_4x64x64:
dotprod_novnni_4x64x64:

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
	vpbroadcastd zmm31, dword ptr onew[rip] # vpbroadcastd zmm31, dword ptr onew
	vpbroadcastd zmm24, [rdi]               # vpbroadcastd zmm24, signal
	vmovups zmm25, [rsi]                    # vmovups zmm25, weight
	vmovups zmm26, [rsi + 64]               # vmovups zmm26, weight + 64
	vmovups zmm27, [rsi + 128]              # vmovups zmm27, weight + 128
	vmovups zmm28, [rsi + 192]              # vmovups zmm28, weight + 192
	vpmaddubsw zmm29, zmm24, zmm25
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm0 , zmm0 , zmm29
	vpmaddubsw zmm30, zmm24, zmm26
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm6 , zmm6 , zmm30
	vpmaddubsw zmm29, zmm24, zmm27
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm12, zmm12, zmm29
	vpmaddubsw zmm30, zmm24, zmm28
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm18, zmm18, zmm30
	vpbroadcastd zmm24, [rdi + 64]         # vpbroadcastd zmm24, signal + 64
	vpmaddubsw zmm29, zmm24, zmm25
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm1 , zmm1 , zmm29
	vpmaddubsw zmm30, zmm24, zmm26
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm7 , zmm7 , zmm30
	vpmaddubsw zmm29, zmm24, zmm27
	vpmaddwd zmm29, zmm29, zmm31
	vpaddd zmm13, zmm13, zmm29
	vpmaddubsw zmm30, zmm24, zmm28
	vpmaddwd zmm30, zmm30, zmm31
	vpaddd zmm19, zmm19, zmm30
	vpbroadcastd zmm24, [rdi + 128]        # vpbroadcastd zmm24, signal + 128
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
	vpbroadcastd zmm24, [rdi + 192]        # vpbroadcastd zmm24, signal + 192
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

#ifdef __APPLE__
	.section __TEXT,__const
#else
	.section .rodata
#endif
	.p2align 2
onew:
	.word 1, 1

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
