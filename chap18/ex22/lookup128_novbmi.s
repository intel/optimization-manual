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

	.globl _lookup128_novbmi
	.globl lookup128_novbmi

	# void lookup128_novbmi(const uint8_t *in, uint8_t* dict, uint8_t *out, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = dict
	#     rdx = out
	#     rcx = len

	.text

_lookup128_novbmi:
lookup128_novbmi:
	//get data sent to function
	                              # mov rsi, dictionary_bytes
	mov r11, rdi                  # mov r11, in_bytes
	mov rax, rdx                  # mov rax, out_bytes
	mov r9, rcx                   # mov r9d, numOfElements
	xor r8, r8
	//Reorganize dictionary
	vpmovzxbw zmm10, [rsi]
	vpmovzxbw zmm15, [rsi+64]
	vpsllw zmm15, zmm15, 8
	vpord zmm10, zmm15, zmm10
	vpmovzxbw zmm11, [rsi+32]
	vpmovzxbw zmm15, [rsi+96]
	vpsllw zmm15, zmm15, 8
	vpord zmm11, zmm15, zmm11
	//initialize constants
	mov r10, 0x00400040
	vpbroadcastw zmm12, r10d
	mov r10, 0
	vpbroadcastd zmm13, r10d
	mov r10, 0x00ff00ff
	vpbroadcastd zmm14, r10d
	//start iterations
loop:
	vpmovzxbw zmm1, [r11+r8*1]
	vpandd zmm2, zmm1, zmm12
	vpcmpw k1, zmm2, zmm13, 4
	vpermi2w zmm1, zmm10, zmm11
	vpsrlw zmm1{k1}, zmm1, 8
	vpandd zmm1, zmm1, zmm14
	vpmovwb [rax+r8*1], zmm1
	add r8, 32
	cmp r8, r9
	jl loop

	vzeroupper
	ret
