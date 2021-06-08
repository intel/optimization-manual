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


;	.globl ternary_vpternlog

	; void ternary_vpternlog(uint32_t *dest, const uint32_t *src1, const uint32_t *src2, const uint32_t *src3, uint64_t len)
	; On entry:
	;     rcx = dest
	;     rdx = src1
	;     r8 = src2
	;     r9 = src3
	;     [rsp+40] = len  ( must be divisible by 32 )


.code
ternary_vpternlog PROC public
	mov r11, [rsp+40]

	xor rax, rax

mainloop:
	vmovaps zmm1, [r8+rax*4]
	vmovaps zmm0, [rdx+rax*4]
	vpternlogd zmm0,zmm1,[r9], 92h
	vmovaps [rcx], zmm0
	vmovaps zmm1, [r8+rax*4+40h]
	vmovaps zmm0, [rdx+rax*4+40h]
	vpternlogd zmm0,zmm1, [r9+40h], 92h
	vmovaps [rcx+40h], zmm0
	add rax, 32
	add r9, 80h
	add rcx, 80h
	cmp rax, r11
	jne mainloop

	vzeroupper
	ret

ternary_vpternlog ENDP
end