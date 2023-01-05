/*
 * Copyright (C) 2022 by Intel Corporation
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef AMX_REF_GEMM_INT8_HPP
#define AMX_REF_GEMM_INT8_HPP

#include <stddef.h>
#include <stdint.h>

#define M 64            // Number of rows in the A or C matrices
#define K 64            // Number of columns in the A or rows in the B matrices
#define N 32            // Number of columns in the B or C matrices
#define M_ACC 4         // Number of C accumulators spanning the M dimension
#define N_ACC 2         // Number of C accumulators spanning the N dimension
#define TILE_M 16       // Number of rows in an A or C tile
#define TILE_K 64       // Number of columns in an A tile or rows in a B tile
#define TILE_N 16       // Number of columns in a B or C tile

typedef int8_t type_t;     // The type of the data being operated on
typedef int32_t res_type_t; // The data type of the result

#define KPACK (4/sizeof(type_t)) // Vertical K packing into Dword

type_t A_mem[M][K];              // A matrix
type_t B_mem[K/KPACK][N][KPACK]; // B matrix
res_type_t C_mem[M][N];          // C matrix

template<size_t rows, size_t bytes_cols> class tile;

template<class T> void tilezero (T& t);
template<class T> void tileload (T& t, void* src, size_t stride);
template<class T> void tilestore(T& t, void* dst, size_t stride);
template<class TC, class TA, class TB> void tdp(TC& tC, TA& tA, TB& tB);

#endif
