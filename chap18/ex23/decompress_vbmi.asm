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

;	.globl decompress_vbmi

	; void decompress_vbmi(uint8_t *out, const uint8_t *in, int len);
	; On entry:
	;     rcx = out
	;     rdx = in
	;     r8 = len


_RDATA SEGMENT    READ ALIGN(64) 'DATA'

permute_ctrl    DB 0, 1, 2, 3, 4, 0,0,0
                DB 5, 6, 7, 8, 9, 0,0,0
                DB 10,11,12,13,14,0,0,0
                DB 15,16,17,18,19,0,0,0
                DB 20,21,22,23,24,0,0,0
                DB 25,26,27,28,29,0,0,0
                DB 30,31,32,33,34,0,0,0
                DB 35,36,37,38,39,0,0,0

multishift_ctrl DB 0, 5, 10,15,20,25,30,35
                DB 0, 5, 10,15,20,25,30,35
                DB 0, 5, 10,15,20,25,30,35
                DB 0, 5, 10,15,20,25,30,35
                DB 0, 5, 10,15,20,25,30,35
                DB 0, 5, 10,15,20,25,30,35
                DB 0, 5, 10,15,20,25,30,35
                DB 0, 5, 10,15,20,25,30,35

_RDATA ENDS

.code
decompress_vbmi PROC public
;	//asm:
	                                   ; mov rdx, compressedData
	                                   ; mov rcx, decompressedData
;	mov r8d, edx                       ; mov r8d,numOfElements
	lea r8, [rcx+r8]
	mov r9, 1F1F1F1Fh
	vpbroadcastd zmm4, r9d
	vmovdqu32 zmm0, zmmword ptr permute_ctrl
	vmovdqu32 zmm3, zmmword ptr multishift_ctrl
loop_start:
	vmovdqu32 zmm1, [rdx]
	vpermb zmm2, zmm0, zmm1
	vpmultishiftqb zmm2, zmm3, zmm2
	vpandq zmm2, zmm4, zmm2
	vmovdqu32 [rcx], zmm2
	add rcx, 64
	add rdx, 40
	cmp rcx, r8
	jl loop_start

	vzeroupper
	ret
decompress_vbmi ENDP
end