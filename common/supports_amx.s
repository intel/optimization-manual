#
# Copyright (C) 2022 by Intel Corporation
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

	.globl _cpu_supports_amx
	.globl cpu_supports_amx

	# int64_t cpu_supports_amx(void);
        #
	# On exit
	#     eax = 1 - AMX is supported (but may need to be enabled in the OS)
	#     eax = 0 - AMX is not supported

	.text

_cpu_supports_amx:
cpu_supports_amx:

	push rbx

	mov eax, 1
	cpuid
	and ecx, 0x008000000
	cmp ecx, 0x008000000	# check OSXSAVE feature flags
	jne not_supported	# XGETBV is enabled by OS

	mov ecx, 0		# specify 0 for XFEATURE_ENABLED_MASK register
	xgetbv			# result in EDX:EAX
	and eax, 0x60000
	cmp eax, 0x60000	# check OS has support for XTILECFG and XTILEDATA
	jne not_supported

	mov eax, 7
	mov ecx, 0
	cpuid

	test edx, 0x3400000	# Check for AMX INT8/BF16/TILE
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
