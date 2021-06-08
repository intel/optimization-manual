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

;	.globl vpgatherd_soft8

	; void vpgatherd_soft8(uint32_t *indices, uint32_t* in, uint32_t* out);
	; On entry:
	;     rcx = indices
	;     rdx = in
	;     r8 = out


.code
vpgatherd_soft8 PROC public
	mov eax, dword ptr [rcx]		; load index0
	vmovd xmm0, dword ptr[rdx+4*rax]			; load element0
	mov eax, [rcx+4]			; load index1
	vpinsrd xmm0, xmm0, dword ptr[rdx+4*rax], 1	; load element1
	mov eax, [rcx+8]			; load index2
	vpinsrd xmm0, xmm0, dword ptr[rdx+4*rax], 2	; load element2
	mov eax, [rcx+12] 			; load index3
	vpinsrd xmm0, xmm0, dword ptr[rdx+4*rax], 3	; load element3
	mov eax, [rcx+16]			; load index4
	vmovd xmm1, dword ptr[rdx+4*rax]			; load element4
	mov eax, [rcx+20]			; load index5
	vpinsrd xmm1, xmm1, dword ptr[rdx+4*rax], 1	; load element5
	mov eax, [rcx+24]			; load index6
	vpinsrd xmm1, xmm1, dword ptr[rdx+4*rax], 2	; load element6
	mov eax, [rcx+28]			; load index7
	vpinsrd xmm1, xmm1, dword ptr[rdx+4*rax], 3	; load element7
	vinserti128 ymm0, ymm0, xmm1, 1		; result in ymm0
	vmovdqu ymmword ptr [r8], ymm0

	vzeroupper
	ret
vpgatherd_soft8 ENDP
end