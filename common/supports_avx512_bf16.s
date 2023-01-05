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

	.globl _supports_avx512_bf16
	.globl supports_avx512_bf16

	# int64_t supports_avx512_bf16(void);
	#
	# On exit
	#     EAX will be set to 1 if AVX512_BF16 is supported, and 0 otherwise.

	.text

_supports_avx512_bf16:
supports_avx512_bf16:

	push rbx

	mov eax, 7
	mov ecx, 1
	cpuid

	test eax, 0x20	        # Check for AVX512_BF16
	jz not_supported

	mov eax, 1
	pop rbx
	ret

not_supported:
	mov eax, 0

	pop rbx
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
