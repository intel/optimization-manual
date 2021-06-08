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

	.globl _lookup_vbmi
	.globl lookup_vbmi

	# void lookup_vbmi(const uint8_t *in, uint8_t* dict, uint8_t *out, size_t len);
	# On entry:
	#     rdi = in
	#     rsi = dict
	#     rdx = out
	#     rcx = len

	.text

_lookup_vbmi:
lookup_vbmi:
	                              # mov rsi, dictionary_bytes
	mov r11, rdi                  # mov r11, in_bytes
	mov rax, rdx                  # mov rax, out_bytes
	mov r9, rcx                   # mov r9d, numOfElements
	xor r8, r8
	vmovdqu32 zmm2, [rsi]

loop:
	vmovdqu32 zmm1, [r11+r8*1]
	vpermb zmm1, zmm1, zmm2
	vmovdqu32 [rax+r8*1], zmm1
	add r8, 64
	cmp r8, r9
	jl loop

	vzeroupper	
	ret
