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


;	.globl avx512_vector_dp

	; double avx512_vector_dp(const uint32_t *a_index, const double *a_value,
	;			  const uint32_t *b_index, const double *b_value,
	;			  uint64_t max_els);
	;
	; On entry:
	;     rcx = a_index
	;     rdx = a_value
	;     r8 = b_index
	;     r9 = b_value
	;     [rsp+96] = max_els

_RDATA SEGMENT    READ ALIGN(64) 'DATA'

all_31s     DQ 0000001f0000001fh
			DQ 0000001f0000001fh
			DQ 0000001f0000001fh
			DQ 0000001f0000001fh
			DQ 0000001f0000001fh
			DQ 0000001f0000001fh
			DQ 0000001f0000001fh
			DQ 0000001f0000001fh
upconvert_control   DQ 0000000000000000h
					DQ 0000000000000001h
					DQ 0000000000000002h
					DQ 0000000000000003h
					DQ 0000000000000004h
					DQ 0000000000000005h
					DQ 0000000000000006h
					DQ 0000000000000007h

_RDATA ENDS



.code
avx512_vector_dp PROC public

	push rbx
	push rsi
	push rbp
	push r12
	push r13
	push r14
	push r15

	mov rsi, [rsp+96]

	mov rbp, rsp
	and rsp, -10h
	sub rsp, 112
	vmovaps xmmword ptr[rsp], xmm6
	vmovaps xmmword ptr[rsp+16], xmm7
	vmovaps xmmword ptr[rsp+32], xmm8
	vmovaps xmmword ptr[rsp+48], xmm9
	vmovaps xmmword ptr[rsp+64], xmm10
	vmovaps xmmword ptr[rsp+80], xmm11
	vmovaps xmmword ptr[rsp+96], xmm12

	mov r11, rsi
	sub r11, 8

	xchg r8, rcx			; mov r8, A_index
	xor rbx, rbx
	xchg r9, rbx			; mov r9, A_offset
							; mov rdx, A_value
	mov r12, rcx			; mov r12, B_index
	xor r13, r13			; mov r13, B_offset
					; mov rbx, B_value

	vpxord zmm4, zmm4, zmm4
	lea r14, all_31s		; mov r14, all_31s	// array of {31, 31, ...}
	vmovaps zmm2, [r14]
	lea r15, upconvert_control ; mov r15, upconvert_control // array of {0, 7, 0, 6, 0, 5, 0, 4, 0, 3, 0, 2, 0, 1, 0, 0}
	vmovaps zmm1, [r15]
	vpternlogd zmm0, zmm0, zmm0, 255
	mov eax, 21845
	kmovw k1, eax 			; odd bits set

loop1:
	cmp r9, r11
	ja vector_end

	cmp r13, r11
	ja vector_end

	; read 8 indices for A
	vmovdqu ymm5, YMMWORD PTR [r8+r9*4]
	; read 8 indices for B, and put
	; them in the high part of zmm6
	vinserti64x4 zmm6, zmm5, YMMWORD PTR [r12+r13*4], 1
	vpconflictd zmm7, zmm6
	; extract A vs. B comparisons
	vextracti64x4 ymm8, zmm7, 1
	; convert comparison results to
	; permute control
	vplzcntd zmm9, zmm8
	vptestmd k2, zmm8, zmm0
	vpsubd zmm10, zmm2, zmm9
	; upconvert permute controls from
	; 32b to 64b, since data is 64b
	vpermd zmm11{k1}, zmm1, zmm10
	; Move A values to corresponding
	; B values, and do FMA
	vpermpd zmm12{k2}{z}, zmm11, [rdx+r9*8]
	vfmadd231pd zmm4, zmm12, [rbx+r13*8]

	; Update the offsets

	mov eax, dword ptr [r8+r9*4+28]
	mov r10d, dword ptr [r12+r13*4+28]
	cmp eax, r10d
	ja a_has_biggest_index
	jb b_has_biggest_index
	add r9, 8
	add r13, 8
	jmp loop1

a_has_biggest_index:
	vpcmpd k3, ymm5, DWORD bcst[r12+r13*4+28], 1
	add r13, 8
	kmovd eax, k3
	lzcnt eax, eax
	add r9, 32
	sub r9, rax
	jmp loop1


b_has_biggest_index:
	vextracti64x4 ymm5, zmm6, 1
	vpcmpd k3, ymm5, DWORD bcst [r8+r9*4+28], 1
	add r9, 8
	kmovd eax, k3
	lzcnt eax, eax
	add r13, 32
	sub r13, rax
	jmp loop1

vector_end:
	vextracti64x4 ymm3, zmm4, 1
	vaddpd ymm4, ymm3, ymm4
	vextracti32x4 xmm3, ymm4, 1
	vzeroupper
	vaddpd xmm0, xmm3, xmm4
	haddpd xmm0, xmm0

scalar_loop:
	cmp r9, rsi
	jae end_loop

	cmp r13, rsi
	jae end_loop

	mov r10d, dword ptr [r8+r9*4]
	mov r11d, dword ptr [r12+r13*4]
	cmp r10d, r11d
	jne skip_fma

;	// do the fma on a match
	movsd xmm5, QWORD PTR [rbx+r13*8]
	mulsd xmm5, QWORD PTR [rdx+r9*8]
	addsd xmm0, xmm5
	inc r9
	inc r13
	jmp scalar_loop

skip_fma:
	jae increment_b
	inc r9
	jmp scalar_loop
increment_b:
	inc r13
	jmp scalar_loop

end_loop:

	vmovaps xmm6, xmmword ptr[rsp]
	vmovaps xmm7, xmmword ptr[rsp+16]
	vmovaps xmm8, xmmword ptr[rsp+32]
	vmovaps xmm9, xmmword ptr[rsp+48]
	vmovaps xmm10, xmmword ptr[rsp+64]
	vmovaps xmm11, xmmword ptr[rsp+80]
	vmovaps xmm12, xmmword ptr[rsp+96]
	
	mov rsp, rbp

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rsi
	pop rbx

	ret

avx512_vector_dp ENDP
end