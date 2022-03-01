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

	.globl _lookup_novbmi
	.globl lookup_novbmi

	# void lookup_novbmi(const uint8_t *in, uint8_t* dict, uint8_t *out, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = dict
	#     rdx = out
	#     rcx = len

	.text

_lookup_novbmi:
lookup_novbmi:
	                              # mov rsi, dictionary_bytes
	mov r11, rdi                  # mov r11, in_bytes
	mov rax, rdx                  # mov rax, out_bytes
	mov r9, rcx                   # mov r9d, numOfElements
	xor r8, r8
	vpmovzxbw zmm3, [rsi]
	vpmovzxbw zmm4, [rsi+32]

loop:
	vpmovzxbw zmm1, [r11+r8*1]
	vpmovzxbw zmm2, [r11+r8*1+32]
	vpermi2w zmm1, zmm3, zmm4
	vpermi2w zmm2, zmm3, zmm4
	vpmovwb [rax+r8*1], zmm1
	vpmovwb [rax+r8*1+32], zmm2
	add r8, 64
	cmp r8, r9
	jl loop

	vzeroupper
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
