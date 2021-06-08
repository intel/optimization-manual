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

	.globl _both_256_512bit
	.globl both_256_512bit

	# void both_256_512bit(uint64_t count);

	.text

_both_256_512bit:
both_256_512bit:

	mov rax, 33
	push rax
	mov rdx, rdi

Loop:
	vpbroadcastd zmm0, dword ptr [rsp]
	vfmadd213ps ymm7, ymm7, ymm7
	vfmadd213ps ymm8, ymm8, ymm8
	vfmadd213ps ymm9, ymm9, ymm9
	vfmadd213ps ymm10, ymm10, ymm10
	vfmadd213ps ymm11, ymm11, ymm11
	vfmadd213ps ymm12, ymm12, ymm12
	vfmadd213ps ymm13, ymm13, ymm13
	vfmadd213ps ymm14, ymm14, ymm14
	vfmadd213ps ymm15, ymm15, ymm15
	vfmadd213ps ymm16, ymm16, ymm16
	vfmadd213ps ymm17, ymm17, ymm17
	vfmadd213ps ymm18, ymm18, ymm18
	vpermd ymm1, ymm1, ymm1
	vpermd ymm2, ymm2, ymm2
	vpermd ymm3, ymm3, ymm3
	vpermd ymm4, ymm4, ymm4
	vpermd ymm5, ymm5, ymm5
	vpermd ymm6, ymm6, ymm6
	dec rdx
	jnle Loop

	pop rax

	vzeroupper

	ret
