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


;	.globl supports_avx512

	; int64_t supports_avx512(uint32_t ecx_in, uint32_t *ebx, uint32_t *ecx, uint32_t *edx);
	;
	; On entry
	;    ecx - value to move into ecx before calling cpuid for the last time.
	;    rdx - pointer to a 32 bit integer that will store the value of ebx after cpuid(7,edi)
	;    r8 - pointer to a 32 bit integer that will store the value of ecx after cpuid(7,edi)
	;    r9 - pointer to a 32 bit integer that will store the value of edx after cpuid(7,edi)

	; On exit
	;     If AVX512_F is not supported eax will be 0.  Otherwise,
	;     the relevant bits of *ebx, *ecx and *edx will be set and eax will be 1.


.code
supports_avx512 PROC public
	push rbx
	mov r10d, ecx
	mov r11, rdx

	mov eax, 1
	cpuid
	and ecx, 008000000h
	cmp ecx, 008000000h	; check OSXSAVE feature flags
	jne not_supported	; XGETBV is enabled by OS

	mov ecx, 0		; specify 0 for XFEATURE_ENABLED_MASK register
	xgetbv			; result in EDX:EAX
	and eax, 0e6h
	cmp eax, 0e6h		; check OS has enabled both ZMM16-31 and upper bits of ZMM0-15
	jne not_supported

	mov eax, 7
	mov ecx, r10d
	cpuid

	test ebx, 10000h	; Check for AVX512F
	jz not_supported

	mov dword ptr[r11], ebx
	mov dword ptr[r8], ecx
	mov dword ptr[r9], edx

	mov eax, 1
	pop rbx
	ret

not_supported:
	mov eax, 0
	pop rbx
	ret
supports_avx512 ENDP
end
