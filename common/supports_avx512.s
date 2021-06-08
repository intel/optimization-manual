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

	.globl _supports_avx512
	.globl supports_avx512

	# int64_t supports_avx512(uint32_t ecx_in, uint32_t *ebx, uint32_t *ecx, uint32_t *edx);
	#
	# On entry
	#     edi - value to move into ecx before calling cpuid for the last time.
	#     rsi - pointer to a 32 bit integer that will store the value of ebx after cpuid(7,edi)
	#     rdx - pointer to a 32 bit integer that will store the value of ecx after cpuid(7,edi)
	#     rcx - pointer to a 32 bit integer that will store the value of edx after cpuid(7,edi)

	# On exit
	#     If AVX512_F is not supported eax will be 0.  Otherwise,
	#     the relevant bits of *ebx, *ecx and *edx will be set and eax will be 1.

	.text

_supports_avx512:
supports_avx512:

	push rbx

	mov r8, rdx
	mov r9, rcx
	mov eax, 1
	cpuid
	and ecx, 0x008000000
	cmp ecx, 0x008000000	# check OSXSAVE feature flags
	jne not_supported	# XGETBV is enabled by OS

	mov ecx, 0		# specify 0 for XFEATURE_ENABLED_MASK register
	xgetbv			# result in EDX:EAX
	and eax, 0xe6
	cmp eax, 0xe6		# check OS has enabled both ZMM16-31 and upper bits of ZMM0-15
	jne not_supported

	mov eax, 7
	mov ecx, edi
	cpuid

	test ebx, 0x10000	# Check for AVX512F
	jz not_supported

	mov dword ptr[rsi], ebx
	mov dword ptr[r8], ecx
	mov dword ptr[r9], edx

	mov eax, 1
	pop rbx
	ret

not_supported:
	mov eax, 0

	pop rbx
	ret
