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

	.globl _peel
	.globl peel

	# void peel(float *out, const float *in, uint64_t width, float add_value, float alfa);
	# On entry:
	#     rdi = out
	#     rsi = in
	#     rdx = width

	.text

_peel:
peel:

	push rbx

	mov rax, rsi                          # mov rax, pImage ( Input )
	mov rbx, rdi                          # mov rbx, pOutImage ( Output )
	mov rcx, rdx                          # mov rcx, len
	                                      # movss xmm0, addValue
	vpbroadcastd zmm0, xmm0
	                                      # movss xmm1, alfa
	vpbroadcastd zmm3, xmm1

	xor r8, r8
	xor r9, r9
	vmovups zmm10, indices[rip]           # vmovups zmm10, [indices]
	vpbroadcastd zmm12, ecx
peeling:
	mov rdx, rbx
	and rdx, 0x3F
	jz endofpeeling                       # nothing to peel
	neg rdx
	add rdx, 64                           # 64 - X
	# now in rdx we have the number of bytes to the closest alignment
	mov r9, rdx
	sar r9, 2                             # now r9 contains number of elements in peeling
	vpbroadcastd zmm12, r9d
	vpcmpd k2, zmm10, zmm12, 1            # compare lower to produce mask for peeling
	vmovups zmm1 {k2}{z}, [rax]
	vfmadd213ps zmm1 {k2}{z}, zmm3, zmm0
	vmovups [rbx] {k2}, zmm1              # unaligned store
endofpeeling:
	sub rcx, r9
	mov r8, rcx
	sar r8, 4                             # number of full iterations
	jz remainder                          # no full iterations

mainloop:
	vmovups zmm1, [rax + rdx]
	vfmadd213ps zmm1, zmm3, zmm0
	vmovaps [rbx + rdx], zmm1             # aligned store is safe here !!
	add rdx, 0x40
	sub r8, 1
	jne mainloop
remainder:
	# produce mask for remainder
	and rcx, 0xF                          # number of elements in remainder
	jz end                                # no elements in remainder
	vpbroadcastd zmm2, ecx
	vpcmpd k2, zmm10, zmm2, 1             # compare lower
	vmovups zmm1 {k2}{z}, [rax + rdx]
	vfmadd213ps zmm1 {k2}{z}, zmm3, zmm0
	vmovaps [rbx + rdx] {k2}, zmm1        # aligned
end:

	vzeroupper
	pop rbx

	ret

indices:
	.int 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
