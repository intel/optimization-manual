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


;	.globl avx512_histogram

	; void avx512_histogram(const int32_t *input, uint32_t *output, uint64_t num_inputs, uint64_t bins);
	;
	; On entry:
	;     rcx = input
	;     rdx = ouptut
	;     r8 = num_inputs
	;     r9 = bins


.code
avx512_histogram PROC public

	sub rsp, 56
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8

	mov eax, 1
	movd xmm4, eax
	vpbroadcastd zmm4, xmm4		; vmovaps zmm4, all_1 // {1, 1, ..., 1}
	mov eax, -1
	movd xmm5, eax
	vpbroadcastd zmm5, xmm5		; vmovaps zmm5, all_negative_1
	mov eax, 31
	movd xmm6, eax
	vpbroadcastd zmm6, xmm6		; vmovaps zmm6, all_31
	dec r9
	movd xmm7, r9d
	vpbroadcastd zmm7, xmm7		; vmovaps zmm7, all_bins_minus_1
								; mov r8d, num_inputs
								; mov rcx, pInput
	mov rdx, rdx			; mov rdx, pHistogram
	xor r9, r9
histogram_loop:
	vpandd zmm3, zmm7, [rcx+r9*4]
	vpconflictd zmm0, zmm3
	kxnorw k1, k1, k1
	vmovaps zmm2, zmm4
	vpxord zmm1, zmm1, zmm1
	vpgatherdd zmm1{k1}, [rdx+zmm3*4]
	vptestmd k1, zmm0, zmm0
	kortestw k1, k1
	je update
	vplzcntd zmm0, zmm0
	vpsubd zmm0, zmm6, zmm0
conflict_loop:
	vpermd zmm8{k1}{z}, zmm0, zmm2
	vpermd zmm0{k1}, zmm0, zmm0
	vpaddd zmm2{k1}, zmm2, zmm8
	vpcmpd k1, zmm5, zmm0, 4	; vpcmpned k1, zmm5, zmm0
	kortestw k1, k1
	jne conflict_loop
update:
	vpaddd zmm0, zmm2, zmm1
	kxnorw k1, k1, k1
	add r9, 16
	vpscatterdd [rdx+zmm3*4]{k1}, zmm0
	cmp r9d, r8d
	jb histogram_loop

	vzeroupper

	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm6, xmmword ptr[rsp]
	add rsp, 56

	ret

avx512_histogram ENDP
end
