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

;	.globl decompress_novbmi

	; void decompress_novbmi(int len, uint8_t *out, const uint8_t *in);
	; On entry:
	;     ecx = len
	;     rdx = out
	;     r8 = in

.code
decompress_novbmi PROC public
	                                     ; mov rdx, compressedData
	mov r9, rdx                          ; mov r9, decompressedData
	mov eax, ecx                         ; mov eax, numOfElements
	shr eax, 3
	xor rdx, rdx
lp:
	mov rcx, qword ptr [r8]
	mov r10, rcx
	and r10, 1fh
	mov r11, rcx
	mov byte ptr [r9+rdx*8], r10b
	mov r10, rcx
	shr r10, 0ah
	add r8, 5h
	and r10, 1fh
	mov byte ptr [r9+rdx*8+2h], r10b
	mov r10, rcx
	shr r10, 0fh
	and r10, 1fh
	mov byte ptr [r9+rdx*8+3h], r10b
	mov r10, rcx
	shr r10, 14h
	and r10, 1fh
	mov byte ptr [r9+rdx*8+4h], r10b
	mov r10, rcx
	shr r10, 19h
	and r10, 1fh
	mov byte ptr [r9+rdx*8+5h], r10b
	mov r10, rcx
	shr r11, 5h
	shr r10, 1eh
	and r11, 1fh
	shr rcx, 23h
	and r10, 1fh
	and rcx, 1fh
	mov byte ptr [r9+rdx*8+1h], r11b
	mov byte ptr [r9+rdx*8+6h], r10b
	mov byte ptr [r9+rdx*8+7h], cl
	inc rdx
	cmp rdx, rax
	jb lp

	ret
decompress_novbmi ENDP
end