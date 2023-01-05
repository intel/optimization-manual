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

#ifndef AMX_REF_GEMM_HPP
#define AMX_REF_GEMM_HPP

void amx_ref_gemm()
{
    for (int n = 0; n < N; n += N_ACC * TILE_N) {
        for (int m = 0; m < M; m += M_ACC * TILE_M) {
            tile<TILE_M, TILE_N * sizeof(res_type_t)> tC[M_ACC][N_ACC];
            for (int n_acc = 0; n_acc < N_ACC; ++n_acc)
                for (int m_acc = 0; m_acc < M_ACC; ++m_acc)
                    tilezero(tC[m_acc][n_acc]);

            for (int k = 0; k < K; k += TILE_K) {
                for (int n_acc = 0; n_acc < N_ACC; ++n_acc) {
                    tile<TILE_K / KPACK, TILE_N * KPACK> tB;
                    tileload(tB, B_mem[k / KPACK][n + n_acc * TILE_N],
                             N * sizeof(type_t) * KPACK);
                    for (int m_acc = 0; m_acc < M_ACC; ++m_acc) {
                        tile<TILE_M, TILE_K * sizeof(type_t)> tA;
                        tileload(tA, &A_mem[m + m_acc * TILE_M][k],
                                 K * sizeof(type_t));
                        tdp(tC[m_acc][n_acc], tA, tB);
                    }
                }
            }
            for (int n_acc = 0; n_acc < N_ACC; ++n_acc) {
                for (int m_acc = 0; m_acc < M_ACC; ++m_acc) {
                    int mc = m + m_acc * TILE_M, nc = n + n_acc * TILE_N;
                    tilestore(tC[m_acc][n_acc], &C_mem[mc][nc],
                              N * sizeof(res_type_t));
                }
            }
        }
    }
}

#endif
