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

	.globl _expand_scalar
	.globl expand_scalar

	# void expand_scalar(int32_t *out, int32_t *in, size_t N);
	# On entry:
	#     rdi = a
	#     rsi = b
	#     rdx = N

	.text

_expand_scalar:
expand_scalar:

				# mov rsi, input
				# mov rdi, output
	mov r9, rdx		# mov r9, len
	xor r8, r8
	xor r10, r10

mainloop:
	mov r11d, dword ptr [rsi+r8*4]
	test r11d, r11d
	jle m1
	mov r11d, dword ptr [rsi+r10*4]
	mov dword ptr [rdi+r8*4], r11d
	inc r10
m1:
	inc r8
	cmp r8, r9
	jne mainloop

	ret
