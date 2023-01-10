;
; Copyright (C) 2022 by Intel Corporation
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

;	.globl mul_nomask_avx512

;	# void mul_nomask_avx512(float *a, float *b, float *out1, float *out2,
;	#	size_t N);

;	# On entry:
;	# rcx = a
;	# rdx = b
;	# r8 = out1
;	# r9 = out2
;	# [rsp+40]  = N

.code
mul_nomask_avx512 PROC public

	vmovups zmm3, zmmword ptr [rcx]   ; vmovups zmm3, a
	vmovups zmm2, zmmword ptr [rdx]   ; vmovups zmm2, b
	vmovups zmm0, zmmword ptr [r8]    ; vmovups zmm0, out1
	vmovups zmm1, zmmword ptr [r9]    ; vmovups zmm1, out2
	mov rax, [rsp+40]                 ; mov rax, N

loop1:
	vmulps zmm0, zmm3, zmm2
	vmulps zmm1, zmm3, zmm2
	dec rax
	jnle loop1

	vmovups zmmword ptr [r8], zmm0
	vmovups zmmword ptr [r9], zmm1

	vzeroupper
	ret
mul_nomask_avx512 ENDP
end
