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

;	.globl avx2_compress

	; uint64_t avx2_compress(uint32_t *out, const uint32_t *in, uint64_t len)
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = len

	; On exit
	;     rax = out_len


_RDATA SEGMENT    READ ALIGN(32) 'DATA'

shuffle_LUT DD 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 01h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 00h, 00h, 00h, 00h, 00h, 00h
DD 02h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 00h, 00h, 00h, 00h, 00h, 00h
DD 01h, 02h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 00h, 00h, 00h, 00h, 00h
DD 03h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 00h, 00h, 00h, 00h, 00h, 00h
DD 01h, 03h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 00h, 00h, 00h, 00h, 00h
DD 02h, 03h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 00h, 00h, 00h, 00h, 00h
DD 01h, 02h, 03h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 00h, 00h, 00h, 00h
DD 04h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 04h, 00h, 00h, 00h, 00h, 00h, 00h
DD 01h, 04h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 04h, 00h, 00h, 00h, 00h, 00h
DD 02h, 04h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 04h, 00h, 00h, 00h, 00h, 00h
DD 01h, 02h, 04h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 04h, 00h, 00h, 00h, 00h
DD 03h, 04h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 04h, 00h, 00h, 00h, 00h, 00h
DD 01h, 03h, 04h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 04h, 00h, 00h, 00h, 00h
DD 02h, 03h, 04h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 04h, 00h, 00h, 00h, 00h
DD 01h, 02h, 03h, 04h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 04h, 00h, 00h, 00h
DD 05h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 05h, 00h, 00h, 00h, 00h, 00h, 00h
DD 01h, 05h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 05h, 00h, 00h, 00h, 00h, 00h
DD 02h, 05h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 05h, 00h, 00h, 00h, 00h, 00h
DD 01h, 02h, 05h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 05h, 00h, 00h, 00h, 00h
DD 03h, 05h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 05h, 00h, 00h, 00h, 00h, 00h
DD 01h, 03h, 05h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 05h, 00h, 00h, 00h, 00h
DD 02h, 03h, 05h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 05h, 00h, 00h, 00h, 00h
DD 01h, 02h, 03h, 05h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 05h, 00h, 00h, 00h
DD 04h, 05h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 04h, 05h, 00h, 00h, 00h, 00h, 00h
DD 01h, 04h, 05h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 04h, 05h, 00h, 00h, 00h, 00h
DD 02h, 04h, 05h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 04h, 05h, 00h, 00h, 00h, 00h
DD 01h, 02h, 04h, 05h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 04h, 05h, 00h, 00h, 00h
DD 03h, 04h, 05h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 04h, 05h, 00h, 00h, 00h, 00h
DD 01h, 03h, 04h, 05h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 04h, 05h, 00h, 00h, 00h
DD 02h, 03h, 04h, 05h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 04h, 05h, 00h, 00h, 00h
DD 01h, 02h, 03h, 04h, 05h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 04h, 05h, 00h, 00h
DD 06h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 06h, 00h, 00h, 00h, 00h, 00h, 00h
DD 01h, 06h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 06h, 00h, 00h, 00h, 00h, 00h
DD 02h, 06h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 06h, 00h, 00h, 00h, 00h, 00h
DD 01h, 02h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 06h, 00h, 00h, 00h, 00h
DD 03h, 06h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 06h, 00h, 00h, 00h, 00h, 00h
DD 01h, 03h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 06h, 00h, 00h, 00h, 00h
DD 02h, 03h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 06h, 00h, 00h, 00h, 00h
DD 01h, 02h, 03h, 06h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 06h, 00h, 00h, 00h
DD 04h, 06h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 04h, 06h, 00h, 00h, 00h, 00h, 00h
DD 01h, 04h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 04h, 06h, 00h, 00h, 00h, 00h
DD 02h, 04h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 04h, 06h, 00h, 00h, 00h, 00h
DD 01h, 02h, 04h, 06h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 04h, 06h, 00h, 00h, 00h
DD 03h, 04h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 04h, 06h, 00h, 00h, 00h, 00h
DD 01h, 03h, 04h, 06h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 04h, 06h, 00h, 00h, 00h
DD 02h, 03h, 04h, 06h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 04h, 06h, 00h, 00h, 00h
DD 01h, 02h, 03h, 04h, 06h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 04h, 06h, 00h, 00h
DD 05h, 06h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 05h, 06h, 00h, 00h, 00h, 00h, 00h
DD 01h, 05h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 05h, 06h, 00h, 00h, 00h, 00h
DD 02h, 05h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 05h, 06h, 00h, 00h, 00h, 00h
DD 01h, 02h, 05h, 06h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 05h, 06h, 00h, 00h, 00h
DD 03h, 05h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 05h, 06h, 00h, 00h, 00h, 00h
DD 01h, 03h, 05h, 06h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 05h, 06h, 00h, 00h, 00h
DD 02h, 03h, 05h, 06h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 05h, 06h, 00h, 00h, 00h
DD 01h, 02h, 03h, 05h, 06h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 05h, 06h, 00h, 00h
DD 04h, 05h, 06h, 00h, 00h, 00h, 00h, 00h
DD 00h, 04h, 05h, 06h, 00h, 00h, 00h, 00h
DD 01h, 04h, 05h, 06h, 00h, 00h, 00h, 00h
DD 00h, 01h, 04h, 05h, 06h, 00h, 00h, 00h
DD 02h, 04h, 05h, 06h, 00h, 00h, 00h, 00h
DD 00h, 02h, 04h, 05h, 06h, 00h, 00h, 00h
DD 01h, 02h, 04h, 05h, 06h, 00h, 00h, 00h
DD 00h, 01h, 02h, 04h, 05h, 06h, 00h, 00h
DD 03h, 04h, 05h, 06h, 00h, 00h, 00h, 00h
DD 00h, 03h, 04h, 05h, 06h, 00h, 00h, 00h
DD 01h, 03h, 04h, 05h, 06h, 00h, 00h, 00h
DD 00h, 01h, 03h, 04h, 05h, 06h, 00h, 00h
DD 02h, 03h, 04h, 05h, 06h, 00h, 00h, 00h
DD 00h, 02h, 03h, 04h, 05h, 06h, 00h, 00h
DD 01h, 02h, 03h, 04h, 05h, 06h, 00h, 00h
DD 00h, 01h, 02h, 03h, 04h, 05h, 06h, 00h
DD 07h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 07h, 00h, 00h, 00h, 00h, 00h, 00h
DD 01h, 07h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 07h, 00h, 00h, 00h, 00h, 00h
DD 02h, 07h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 07h, 00h, 00h, 00h, 00h, 00h
DD 01h, 02h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 07h, 00h, 00h, 00h, 00h
DD 03h, 07h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 07h, 00h, 00h, 00h, 00h, 00h
DD 01h, 03h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 07h, 00h, 00h, 00h, 00h
DD 02h, 03h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 07h, 00h, 00h, 00h, 00h
DD 01h, 02h, 03h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 07h, 00h, 00h, 00h
DD 04h, 07h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 04h, 07h, 00h, 00h, 00h, 00h, 00h
DD 01h, 04h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 04h, 07h, 00h, 00h, 00h, 00h
DD 02h, 04h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 04h, 07h, 00h, 00h, 00h, 00h
DD 01h, 02h, 04h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 04h, 07h, 00h, 00h, 00h
DD 03h, 04h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 04h, 07h, 00h, 00h, 00h, 00h
DD 01h, 03h, 04h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 04h, 07h, 00h, 00h, 00h
DD 02h, 03h, 04h, 07h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 04h, 07h, 00h, 00h, 00h
DD 01h, 02h, 03h, 04h, 07h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 04h, 07h, 00h, 00h
DD 05h, 07h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 05h, 07h, 00h, 00h, 00h, 00h, 00h
DD 01h, 05h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 05h, 07h, 00h, 00h, 00h, 00h
DD 02h, 05h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 05h, 07h, 00h, 00h, 00h, 00h
DD 01h, 02h, 05h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 05h, 07h, 00h, 00h, 00h
DD 03h, 05h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 05h, 07h, 00h, 00h, 00h, 00h
DD 01h, 03h, 05h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 05h, 07h, 00h, 00h, 00h
DD 02h, 03h, 05h, 07h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 05h, 07h, 00h, 00h, 00h
DD 01h, 02h, 03h, 05h, 07h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 05h, 07h, 00h, 00h
DD 04h, 05h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 04h, 05h, 07h, 00h, 00h, 00h, 00h
DD 01h, 04h, 05h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 04h, 05h, 07h, 00h, 00h, 00h
DD 02h, 04h, 05h, 07h, 00h, 00h, 00h, 00h
DD 00h, 02h, 04h, 05h, 07h, 00h, 00h, 00h
DD 01h, 02h, 04h, 05h, 07h, 00h, 00h, 00h
DD 00h, 01h, 02h, 04h, 05h, 07h, 00h, 00h
DD 03h, 04h, 05h, 07h, 00h, 00h, 00h, 00h
DD 00h, 03h, 04h, 05h, 07h, 00h, 00h, 00h
DD 01h, 03h, 04h, 05h, 07h, 00h, 00h, 00h
DD 00h, 01h, 03h, 04h, 05h, 07h, 00h, 00h
DD 02h, 03h, 04h, 05h, 07h, 00h, 00h, 00h
DD 00h, 02h, 03h, 04h, 05h, 07h, 00h, 00h
DD 01h, 02h, 03h, 04h, 05h, 07h, 00h, 00h
DD 00h, 01h, 02h, 03h, 04h, 05h, 07h, 00h
DD 06h, 07h, 00h, 00h, 00h, 00h, 00h, 00h
DD 00h, 06h, 07h, 00h, 00h, 00h, 00h, 00h
DD 01h, 06h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 01h, 06h, 07h, 00h, 00h, 00h, 00h
DD 02h, 06h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 02h, 06h, 07h, 00h, 00h, 00h, 00h
DD 01h, 02h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 02h, 06h, 07h, 00h, 00h, 00h
DD 03h, 06h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 03h, 06h, 07h, 00h, 00h, 00h, 00h
DD 01h, 03h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 03h, 06h, 07h, 00h, 00h, 00h
DD 02h, 03h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 02h, 03h, 06h, 07h, 00h, 00h, 00h
DD 01h, 02h, 03h, 06h, 07h, 00h, 00h, 00h
DD 00h, 01h, 02h, 03h, 06h, 07h, 00h, 00h
DD 04h, 06h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 04h, 06h, 07h, 00h, 00h, 00h, 00h
DD 01h, 04h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 04h, 06h, 07h, 00h, 00h, 00h
DD 02h, 04h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 02h, 04h, 06h, 07h, 00h, 00h, 00h
DD 01h, 02h, 04h, 06h, 07h, 00h, 00h, 00h
DD 00h, 01h, 02h, 04h, 06h, 07h, 00h, 00h
DD 03h, 04h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 03h, 04h, 06h, 07h, 00h, 00h, 00h
DD 01h, 03h, 04h, 06h, 07h, 00h, 00h, 00h
DD 00h, 01h, 03h, 04h, 06h, 07h, 00h, 00h
DD 02h, 03h, 04h, 06h, 07h, 00h, 00h, 00h
DD 00h, 02h, 03h, 04h, 06h, 07h, 00h, 00h
DD 01h, 02h, 03h, 04h, 06h, 07h, 00h, 00h
DD 00h, 01h, 02h, 03h, 04h, 06h, 07h, 00h
DD 05h, 06h, 07h, 00h, 00h, 00h, 00h, 00h
DD 00h, 05h, 06h, 07h, 00h, 00h, 00h, 00h
DD 01h, 05h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 01h, 05h, 06h, 07h, 00h, 00h, 00h
DD 02h, 05h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 02h, 05h, 06h, 07h, 00h, 00h, 00h
DD 01h, 02h, 05h, 06h, 07h, 00h, 00h, 00h
DD 00h, 01h, 02h, 05h, 06h, 07h, 00h, 00h
DD 03h, 05h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 03h, 05h, 06h, 07h, 00h, 00h, 00h
DD 01h, 03h, 05h, 06h, 07h, 00h, 00h, 00h
DD 00h, 01h, 03h, 05h, 06h, 07h, 00h, 00h
DD 02h, 03h, 05h, 06h, 07h, 00h, 00h, 00h
DD 00h, 02h, 03h, 05h, 06h, 07h, 00h, 00h
DD 01h, 02h, 03h, 05h, 06h, 07h, 00h, 00h
DD 00h, 01h, 02h, 03h, 05h, 06h, 07h, 00h
DD 04h, 05h, 06h, 07h, 00h, 00h, 00h, 00h
DD 00h, 04h, 05h, 06h, 07h, 00h, 00h, 00h
DD 01h, 04h, 05h, 06h, 07h, 00h, 00h, 00h
DD 00h, 01h, 04h, 05h, 06h, 07h, 00h, 00h
DD 02h, 04h, 05h, 06h, 07h, 00h, 00h, 00h
DD 00h, 02h, 04h, 05h, 06h, 07h, 00h, 00h
DD 01h, 02h, 04h, 05h, 06h, 07h, 00h, 00h
DD 00h, 01h, 02h, 04h, 05h, 06h, 07h, 00h
DD 03h, 04h, 05h, 06h, 07h, 00h, 00h, 00h
DD 00h, 03h, 04h, 05h, 06h, 07h, 00h, 00h
DD 01h, 03h, 04h, 05h, 06h, 07h, 00h, 00h
DD 00h, 01h, 03h, 04h, 05h, 06h, 07h, 00h
DD 02h, 03h, 04h, 05h, 06h, 07h, 00h, 00h
DD 00h, 02h, 03h, 04h, 05h, 06h, 07h, 00h
DD 01h, 02h, 03h, 04h, 05h, 06h, 07h, 00h
DD 00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h

write_mask DD 80000000h, 80000000h, 80000000h, 80000000h
DD 80000000h, 80000000h, 80000000h, 80000000h
DD 00000000h, 00000000h, 00000000h, 00000000h
DD 00000000h, 00000000h, 00000000h, 00000000h

_RDATA ENDS

.code
avx2_compress PROC public

	push r13
	push r14
	push r15
	                                   ; mov rdx, source
	                                   ; mov rcx, dest
	mov r9, r8                         ; mov r9, len
	lea r14, shuffle_LUT               ; mov r14, shuffle_LUT
	lea r15, write_mask                ; mov r15, write_mask

	xor r8, r8
	xor r11, r11
	vpxor ymm0, ymm0, ymm0

mainloop:
	vmovdqa ymm1, ymmword ptr[rdx+r8*4]
	vpcmpgtd ymm2, ymm1, ymm0
	mov r10, 8
	vmovmskps r13, ymm2
	shl r13, 5
	vmovdqu ymm3, ymmword ptr[r14+r13]
	vpermd ymm2, ymm3, ymm1
	popcnt r13, r13
	sub r10, r13
	vmovdqu ymm3, ymmword ptr[r15+r10*4]
	vmaskmovps [rcx+r11*4], ymm3, ymm2
	add r11, r13
	add r8, 8
	cmp r8, r9
	jne mainloop

	vzeroupper

	pop r15
	pop r14
	pop r13

	mov rax, r11

	ret
avx2_compress ENDP
end