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

	.globl _avx512_histogram
	.globl avx512_histogram

	# void avx512_histogram(const int32_t *input, uint32_t *output, uint64_t num_inputs, uint64_t bins);
	#
	# On entry:
	#     rdi = input
	#     rsi = ouptut
	#     rdx = num_inputs
	#     rcx = bins

	.text

_avx512_histogram:
avx512_histogram:

	push rbx
	push r15

	mov eax, 1
	movd xmm4, eax
	vpbroadcastd zmm4, xmm4		# vmovaps zmm4, all_1 // {1, 1, ..., 1}
	mov eax, -1
	movd xmm5, eax
	vpbroadcastd zmm5, xmm5		# vmovaps zmm5, all_negative_1
	mov eax, 31
	movd xmm6, eax
	vpbroadcastd zmm6, xmm6		# vmovaps zmm6, all_31
	dec rcx
	movd xmm7, ecx
	vpbroadcastd zmm7, xmm7		# vmovaps zmm7, all_bins_minus_1	
	mov ebx, edx			# mov ebx, num_inputs
	mov r10, rdi			# mov r10, pInput	
	mov r15, rsi			# mov r15, pHistogram
	xor rcx, rcx
histogram_loop:
	vpandd zmm3, zmm7, [r10+rcx*4]
	vpconflictd zmm0, zmm3
	kxnorw k1, k1, k1
	vmovaps zmm2, zmm4
	vpxord zmm1, zmm1, zmm1
	vpgatherdd zmm1{k1}, [r15+zmm3*4]
	vptestmd k1, zmm0, zmm0
	kortestw k1, k1
	je update
	vplzcntd zmm0, zmm0
	vpsubd zmm0, zmm6, zmm0
conflict_loop:
	vpermd zmm8{k1}{z}, zmm0, zmm2
	vpermd zmm0{k1}, zmm0, zmm0
	vpaddd zmm2{k1}, zmm2, zmm8
	vpcmpd k1, zmm5, zmm0, 4	# vpcmpned k1, zmm5, zmm0
	kortestw k1, k1
	jne conflict_loop
update:
	vpaddd zmm0, zmm2, zmm1
	kxnorw k1, k1, k1
	add rcx, 16
	vpscatterdd [r15+zmm3*4]{k1}, zmm0
	cmp ecx, ebx
	jb histogram_loop

	vzeroupper
	pop r15
	pop rbx

	ret

