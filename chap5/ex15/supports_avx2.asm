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


;	.globl supports_avx2

	; int64_t supports_avx2(void);

	; On exit
	;     eax = 1 if AVX2 is supported, 0 otherwise


.code
supports_avx2 PROC public
				; result in eax
	push rbx
	mov eax, 1
	cpuid
	and ecx, 018000000h
	cmp ecx, 018000000h	; check both OSXSAVE and AVX feature flags
	jne not_supported	; processor supports AVX instructions and XGETBV is enabled by OS
	mov eax, 7
	mov ecx, 0
	cpuid
	and ebx, 20h
	cmp ebx, 20h		; check AVX2 feature flags
	jne not_supported
	mov ecx, 0		; specify 0 for XFEATURE_ENABLED_MASK register
	xgetbv			; result in EDX:EAX
	and eax, 06h
	cmp eax, 06h		; check OS has enabled both XMM and YMM state support
	jne not_supported
	mov eax, 1
	jmp done
not_supported:
	mov eax, 0
done:
	pop rbx
	ret
supports_avx2 ENDP
end