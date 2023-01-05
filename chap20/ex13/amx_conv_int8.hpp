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

#ifndef AMX_CONV_INT8_HPP
#define AMX_CONV_INT8_HPP

#include <stddef.h>
#include <stdint.h>

// clang-format off

#define H 18             // The height of the activation frame
#define W 18             // The width of the activation frame
#define MA (H*W)         // The M dimension (rows) of the A matrix
#define K 4              // Number of activation channels
#define N 16             // Number of output channels
#define KH 3             // The height of the weights kernel
#define KW 3             // The width of the weights kernel
#define SH 1             // The vertical stride of the convolution
#define SW 1             // The horizontal stride of the convolution
#define M_ACC 1          // Number of C accumulators spanning the M dimension
#define N_ACC 1          // Number of C accumulators spanning the N dimension
#define TILE_M 16        // Number of rows in an A or C tile
#define TILE_K 4         // Number of columns in an A tile or rows in a B tile
#define TILE_N 16        // Number of columns in a B or C tile

#define HC ((H-KH)/SH+1) // The height of the output frame
#define WC ((W-KW)/SW+1) // The width of the output frame
#define MC (HC*WC)       // The M dimension (rows) of the C matrix

typedef int8_t type_t;      // The type of the data being operated on
typedef int32_t res_type_t;  // The data type of the result

#define KPACK (4/sizeof(type_t)) // Vertical K packing into Dword

type_t A_mem[H][W][K];                   // A matrix (equivalent to A_mem[H*W][K])
type_t B_mem[KH][KW][K/KPACK][N][KPACK]; // B matrices
res_type_t C_mem[MC][N];                 // C matrix

template<size_t rows, size_t cols> class tile;

template<class T> void tilezero (T& t);
template<class T> void tileload (T& t, void* src, size_t stride);
template<class T> void tilestore(T& t, void* dst, size_t stride);
template<class TC, class TA, class TB> void tdp(TC& tC, TA& tA, TB& tB);

int mc_to_ha(int mc) {return mc / HC * SH;} // C matrix M -> A tensor h coord
int mc_to_wa(int mc) {return mc % HC * SW;} // C matrix M -> A tensor w coord

// clang-format on

#endif
