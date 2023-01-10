#
# Copyright (C) 2022 by Intel Corporation
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

#define K 192
#define N 32
#define TILE_M 2
#define TILE_K 64
#define TILE_N 16
#define K_PACK 4
#define TMP_RES_TYPE_SIZE 4

#define TILE_N_B      (N)
#define A_OFFSET(m,k) ((m)*K*TILE_M + (k)*TILE_K)
#define B_OFFSET(k,n) ((k)*N*TILE_N*4 + (n)*TILE_N*4)
#define C_OFFSET(m,n) ((m)*N*TILE_M + (n)*TILE_N)
#define C_TMP_OFFSET(m,n) ((m)*N*TILE_M*4 + (n)*TILE_N*4)
#define Q_OFFSET(n)      ((n)*TILE_N*4)
#define BIAS_OFFSET(n)   ((n)*TILE_N*4 + N*4)

	.intel_syntax noprefix

	.globl _amx_interleaved_gemm_relu_ass
	.globl amx_interleaved_gemm_relu_ass

	# void amx_interleaved_gemm_relu_ass(int32_t *out_c_tmp, uint8_t *c,
        #                                    const int32_t *in_c_tmp,
	#                                    const uint8_t *a, const int8_t *b,
	#                                    const tc* config, float *qb)

	# On entry:
	#     rdi = out_c_tmp
	#     rsi = c
	#     rdx = in_ctmp
	#     rcx = a
	#     r8 = b
	#     r9 = config
    #     rsp + 8 = qb
	#
	#  - the dimensions of a are expected to be 4x192 uint8
	#  - the dimensions of b are expected to be 48x32x4 int8
	#  - the dimensions of in_c_tmp are expected to be 4x32 int32
       	#  - the dimensions of out_c_tmp are expected to be 4x32 int32
	#  - the dimensions of c are expected to be 4x32 uint8

.text

_amx_interleaved_gemm_relu_ass:
amx_interleaved_gemm_relu_ass:
	push r12
	push r13
	push r14
	push r15

	ldtilecfg [r9]                                            #  Load tile config
	mov r9, r8                                                #  b
	mov r8, rcx                                               #  a
	mov r14, [rsp + 40]                                       #  qb
	mov r11, rdi                                              #  out_c_tmp
	mov r12, rdx                                              #  in_c_tmp
	mov r10, rsi                                              #  c

	mov r15, 192
	mov r13, 128
	tileloadd tmm5, [r9 + r13*1 + B_OFFSET(0,0)]              # Load B [k,n] = [0,0]
	tileloadd tmm4, [r8 + r15*1 + A_OFFSET(0,0)]              # Load A [m,k] = [0,0]
	tilezero tmm0                                             # Zero acc [m,n] = [0,0]
	vcvtdq2ps zmm0, [r12 + C_TMP_OFFSET(0,0) + 0*TILE_N_B]    # int32 -> float
	vmovups zmm1, [r14 + Q_OFFSET(0)]                         # q-factors for N=0
	vmovups zmm2, [r14 + BIAS_OFFSET(0)]                      # biases    for N=0
	vfmadd213ps zmm0, zmm1, zmm2                              # zmm0  = zmm0  * q + b
	vcvtps2dq zmm0, zmm0                                      # float -> int32
	vpxord zmm3, zmm3, zmm3                                   # Prepare zero ZMM
	vpmaxsd zmm0, zmm0, zmm3                                  # RELU (int32)
	tdpbusd tmm0, tmm4, tmm5
	tileloadd tmm6, [r9 + r13*1 + B_OFFSET(0,1)]              # Load B [k,n] = [0,1]
	tilezero tmm2                                             # Zero acc [m,n] = [0,1]
	vpmovusdb [r10 + C_OFFSET(0,0) + 0*TILE_N_B], zmm0        # uint32 -> uint8
	vcvtdq2ps zmm4, [r12 + C_TMP_OFFSET(0,0) + 4*TILE_N_B]    # int32 -> float
	vfmadd213ps zmm4, zmm1, zmm2                              # zmm4  = zmm4  * q + b
	tdpbusd tmm2, tmm4, tmm6
	tileloadd tmm4, [r8 + r15*1 + A_OFFSET(1,0)]              # Load A [m,k] = [1,0]
	tilezero tmm1                                             # Zero acc [m,n] = [1,0]
	vcvtps2dq zmm4, zmm4                                      # float -> int32

	vpmaxsd zmm4, zmm4, zmm3                                  # RELU (int32)
	vpmovusdb [r10 + C_OFFSET(0,0) + 1*TILE_N_B], zmm4        # uint32 -> uint8
	tdpbusd tmm1, tmm4, tmm5
	tilezero tmm3                                             # Zero acc [m,n] = [1,1]
	vcvtdq2ps zmm5, [r12 + C_TMP_OFFSET(1,0) + 0*TILE_N_B]    # int32 -> float
	vfmadd213ps zmm5, zmm1, zmm2                              # zmm5  = zmm5  * q + b
	vcvtps2dq zmm5, zmm5                                      # float -> int32
	vpmaxsd zmm5, zmm5, zmm3                                  # RELU (int32)
	tdpbusd tmm3, tmm4, tmm6
	tileloadd tmm5, [r9 + r13*1 + B_OFFSET(1,0)]              # Load B [k,n] = [1,0]
	tileloadd tmm4, [r8 + r15*1 + A_OFFSET(0,1)]              # Load A [m,k] = [0,1]
	vpmovusdb [r10 + C_OFFSET(1,0) + 0*TILE_N_B], zmm5        # uint32 -> uint8
	vcvtdq2ps zmm6, [r12 + C_TMP_OFFSET(1,0) + 4*TILE_N_B]    # int32 -> float
	vfmadd213ps zmm6, zmm1, zmm2                              # zmm6  = zmm6  * q + b
	tdpbusd tmm0, tmm4, tmm5
	tileloadd tmm6, [r9 + r13*1 + B_OFFSET(1,1)]              # Load B [k,n] = [1,1]
	vcvtps2dq zmm6, zmm6                                      # float -> int32
	vpmaxsd zmm6, zmm6, zmm3                                  # RELU (int32)
	vpmovusdb [r10 + C_OFFSET(1,0) + 1*TILE_N_B], zmm6        # uint32 -> uint8
	tdpbusd tmm2, tmm4, tmm6
	tileloadd tmm4, [r8 + r15*1 + A_OFFSET(1,1)]              # Load A [m,k] = [1,1]
	vcvtdq2ps zmm7 , [r12 + C_TMP_OFFSET(0,1) + 0*TILE_N_B]   # int32 -> float
	vmovups zmm8, [r14 + Q_OFFSET(1)]                         # q-factors for N=1
	vmovups zmm9, [r14 + BIAS_OFFSET(1)]                      # biases    for N=1
	vfmadd213ps zmm7, zmm8, zmm9                              # zmm7  = zmm7  * q + b
	vcvtps2dq zmm7, zmm7                                      # float -> int32
	vpmaxsd zmm7, zmm7, zmm3                                  # RELU (int32)
	tdpbusd tmm1, tmm4, tmm5
	vpmovusdb [r10 + C_OFFSET(0,1) + 0*TILE_N_B], zmm7        # uint32 -> uint8
	vcvtdq2ps zmm10, [r12 + C_TMP_OFFSET(0,1) + 4*TILE_N_B]   # int32 -> float
	vfmadd213ps zmm10, zmm8, zmm9                             # zmm10 = zmm10 * q + b
	tdpbusd tmm3, tmm4, tmm6
	tileloadd tmm5, [r9 + r13*1 + B_OFFSET(2,0)]              # Load B [k,n] = [2,0]
	tileloadd tmm4, [r8 + r15*1 + A_OFFSET(0,2)]              # Load A [m,k] = [0,2]
	vcvtps2dq zmm10, zmm10                                    # float -> int32
	vpmaxsd zmm10, zmm10, zmm3                                # RELU (int32)
	vpmovusdb [r10 + C_OFFSET(0,1) + 1*TILE_N_B], zmm10       # uint32 -> uint8
	tdpbusd tmm0, tmm4, tmm5
	tilestored [r11 + r13*1 + C_TMP_OFFSET(0,0)], tmm0        # Store C tmp [m,n] = [0,0]
	tileloadd tmm6, [r9 + r13*1 + B_OFFSET(2,1)]              # Load B [k,n] = [2,1]
	vcvtdq2ps zmm11, [r12 + C_TMP_OFFSET(1,1) + 0*TILE_N_B]   # int32 -> float
	vfmadd213ps zmm11, zmm8, zmm9                             # zmm11 = zmm11 * q + b
	vcvtps2dq zmm11, zmm11                                    # float -> int32
	vpmaxsd zmm11, zmm11, zmm3                                # RELU (int32)
	tdpbusd tmm2, tmm4, tmm6
	tilestored [r11 + r13*1 + C_TMP_OFFSET(0,1)], tmm2        # Store C tmp [m,n] = [0,1]
	tileloadd tmm4, [r8 + r15*1 + A_OFFSET(1,2)]              # Load A [m,k] = [1,2]
	vpmovusdb [r10 + C_OFFSET(1,1) + 0*TILE_N_B], zmm11       # uint32 -> uint8
	vcvtdq2ps zmm12, [r12 + C_TMP_OFFSET(1,1) + 4*TILE_N_B]   # int32 -> float
	vfmadd213ps zmm12, zmm8, zmm9                             # zmm12 = zmm12 * q + b
	tdpbusd tmm1, tmm4, tmm5
	tilestored [r11 + r13*1 + C_TMP_OFFSET(1,0)], tmm1        # Store C tmp [m,n] = [1,0]
	vcvtps2dq zmm12, zmm12                                    # float -> int32
	vpmaxsd zmm12, zmm12, zmm3                                # RELU (int32)
	vpmovusdb [r10 + C_OFFSET(1,1) + 1*TILE_N_B], zmm12       # uint32 -> uint8
	tdpbusd tmm3, tmm4, tmm6
	tilestored [r11 + r13*1 + C_TMP_OFFSET(1,1)], tmm3        # Store C tmp [m,n] = [1,1]

	# xchg r11, r12                                           # Swap buffers for current/next iter


	tilerelease
	vzeroupper

	pop r15
	pop r14
	pop r13
	pop r12
	ret

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
