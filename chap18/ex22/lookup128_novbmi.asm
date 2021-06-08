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

;	.globl lookup128_novbmi

	; void lookup128_novbmi(const uint8_t *in, uint8_t* dict, uint8_t *out, size_t len);
	; On entry:
	;     rcx = in
	;     rdx = dict
	;     r8 = out
	;     r9 = len

.code

lookup128_novbmi PROC public
;	// store non-volatile registers on stack
	sub rsp, 40
	vmovaps xmmword ptr[rsp], xmm11
	vmovaps xmmword ptr[rsp+16], xmm12
;	//get data sent to function
	                              ; mov rdx, dictionary_bytes
	mov r11, rcx                  ; mov r11, in_bytes
	mov rax, r8                   ; mov rax, out_bytes
;	mov r10, r9                   ; mov r9d, numOfElements
	xor r8, r8
;	//Reorganize dictionary
	vpmovzxbw zmm0, ymmword ptr[rdx]
	vpmovzxbw zmm5, ymmword ptr[rdx+64]
	vpsllw zmm5, zmm5, 8
	vpord zmm0, zmm5, zmm0
	vpmovzxbw zmm11, ymmword ptr[rdx+32]
	vpmovzxbw zmm5, ymmword ptr[rdx+96]
	vpsllw zmm5, zmm5, 8
	vpord zmm11, zmm5, zmm11
;	//initialize constants
	mov r10, 00400040h
	vpbroadcastw zmm12, r10d
	mov r10, 0
	vpbroadcastd zmm3, r10d
	mov r10, 00ff00ffh
	vpbroadcastd zmm4, r10d
;	//start iterations
lp:
	vpmovzxbw zmm1, ymmword ptr[r11+r8*1]
	vpandd zmm2, zmm1, zmm12
	vpcmpw k1, zmm2, zmm3, 4
	vpermi2w zmm1, zmm0, zmm11
	vpsrlw zmm1{k1}, zmm1, 8
	vpandd zmm1, zmm1, zmm4
	vpmovwb ymmword ptr[rax+r8*1], zmm1
	add r8, 32
	cmp r8, r9
	jl lp

	vzeroupper
;	// restore non-volatile registers from stack
	vmovaps xmm12, xmmword ptr[rsp+16]
	vmovaps xmm11, xmmword ptr[rsp]
	add rsp, 40
	ret
lookup128_novbmi ENDP
end