/*
 * Copyright (C) 2023 by Intel Corporation
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

#include <immintrin.h>

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "direct_conv.h"

char *a_buffer;
char *a_buffer_vnni;
char *b_buffer;
char *b_buffer_vnni;
int32_t *c_buffer;
int32_t *c_buffer_vnni;

static bool allocate_buffers(const direct_conv_dims_t *dims)
{
    a_buffer = (char *)malloc(A_SIZE(dims));
    if (!a_buffer)
        return false;

    a_buffer_vnni = (char *)_mm_malloc(A_SIZE(dims), CACHE_LINE_SIZE);
    if (!a_buffer_vnni)
        goto cleanup;

    b_buffer = (char *)malloc(B_SIZE(dims));
    if (!b_buffer)
        goto cleanup;

    b_buffer_vnni = (char *)_mm_malloc(B_SIZE(dims), CACHE_LINE_SIZE);
    if (!b_buffer_vnni)
        goto cleanup;

    c_buffer = (int32_t *)malloc(C_SIZE(dims));
    if (!c_buffer)
        goto cleanup;

    memset(c_buffer, 0, C_SIZE(dims));

    c_buffer_vnni = (int32_t *)_mm_malloc(C_SIZE(dims), CACHE_LINE_SIZE);
    if (!c_buffer_vnni)
        goto cleanup;

    memset(c_buffer_vnni, 0, C_SIZE(dims));

    return true;

cleanup:
    free_data();
    return false;
}

static void populate_buffers(const direct_conv_dims_t *dims)
{
    for (int i = 0; i < A_SIZE(dims); i++)
        a_buffer[i] = i % 127;

    for (int i = 0; i < B_SIZE(dims); i++)
        b_buffer[i] = i;
}

static void relayout_a(const direct_conv_dims_t *dims)
{
    for (int k = 0; k < dims->k_dim; k++) {
        for (int h = 0; h < dims->h_dim; h++) {
            for (int w = 0; w < dims->w_dim; w++) {
                a_buffer_vnni_at(dims, a_buffer_vnni, h, w, k) =
                    a_buffer_at(dims, a_buffer, k, h, w);
            }
        }
    }
}

static void relayout_b(const direct_conv_dims_t *dims)
{
    for (int k_h = 0; k_h < dims->kh; k_h++) {
        for (int k_w = 0; k_w < dims->kw; k_w++) {
            for (int k = 0; k < dims->k_dim; k++) {
                for (int n = 0; n < dims->n_dim; n++) {
                    b_buffer_vnni_at(dims, b_buffer_vnni, k_h, k_w,
                                     k / B_MATRIX_BLOCK, n,
                                     k % B_MATRIX_BLOCK) =
                        b_buffer_at(dims, b_buffer, k, n, k_h, k_w);
                }
            }
        }
    }
}

void direct_conv_ref(const direct_conv_dims_t *dims, const char *a_buffer,
                     const char *b_buffer, int32_t *c_buffer)
{
    for (int n = 0; n < dims->n_dim; n++) {
        for (int h = 0; h < OUT_H(dims); h++) {
            for (int w = 0; w < OUT_W(dims); w++) {
                int c = 0;

                for (int k = 0; k < dims->k_dim; k++) {
                    for (int k_h = 0; k_h < dims->kh; k_h++) {
                        for (int k_w = 0; k_w < dims->kw; k_w++) {
                            int a = a_buffer_at(dims, a_buffer, k,
                                                h * dims->sh + k_h,
                                                w * dims->sw + k_w);
                            int b = b_buffer_at(dims, b_buffer, k, n, k_h, k_w);

                            c += a * b;
                        }
                    }
                }
                c_buffer_at(dims, c_buffer, n, h, w) = c;
            }
        }
    }
}

void direct_conv_opt_scalar(const direct_conv_dims_t *dims,
                            const char *a_buffer_vnni,
                            const char *b_buffer_vnni, int32_t *c_buffer_vnni)
{
    for (int n = 0; n < dims->n_dim; n++) {
        for (int h = 0; h < OUT_H(dims); h++) {
            for (int w = 0; w < OUT_W(dims); w++) {
                int c = 0;

                for (int k = 0; k < dims->k_dim; k++) {
                    for (int k_h = 0; k_h < dims->kh; k_h++) {
                        for (int k_w = 0; k_w < dims->kw; k_w++) {
                            int a = a_buffer_vnni_at(dims, a_buffer_vnni,
                                                     h * dims->sh + k_h,
                                                     w * dims->sw + k_w, k);
                            int b = b_buffer_vnni_at(dims, b_buffer_vnni, k_h,
                                                     k_w, k / B_MATRIX_BLOCK, n,
                                                     k % B_MATRIX_BLOCK);
                            c += a * b;
                        }
                    }
                }
                c_buffer_vnni_at(dims, c_buffer_vnni, h, w, n) = c;
            }
        }
    }
}

void direct_conv_opt(const direct_conv_dims_t *dims, const char *a_buffer_vnni,
                     const char *b_buffer_vnni, int32_t *c_buffer_vnni)
{
    int m_dim = OUT_H(dims) * OUT_W(dims);
    __m512i *cvec =
        _mm_malloc(dims->n_accum * dims->m_accum * sizeof(*cvec), 64);

    for (int n = 0; n < dims->n_dim; n += C_MATRIX_BLOCK * dims->n_accum) {
        // the '1' represents the size of the VNNI register on the M dimension

        for (int m = 0; m < m_dim; m += 1 * dims->m_accum) {
            for (int i = 0; i < dims->n_accum; i++)
                for (int j = 0; j < dims->m_accum; j++)
                    cvec[i * dims->m_accum + j] = _mm512_setzero_epi32();

            for (int ni = 0; ni < dims->n_accum; ni++) {
                int n_final = n + ni * C_MATRIX_BLOCK;

                for (int mi = 0; mi < dims->m_accum; mi++) {
                    int m_final = m + mi;
                    int h = m_final / OUT_W(dims);
                    int w = m_final % OUT_W(dims);

                    for (int k = 0; k < dims->k_dim; k += B_MATRIX_BLOCK) {
                        for (int k_h = 0; k_h < dims->kh; k_h++) {
                            for (int k_w = 0; k_w < dims->kw; k_w++) {
                                const int32_t *a_addr =
                                    (const int32_t *)&a_buffer_vnni_at(
                                        dims, a_buffer_vnni, h * dims->sh + k_h,
                                        w * dims->sw + k_w, k);
                                const int32_t a = *a_addr;
                                __m512i avec = _mm512_set1_epi32(a);

                                const char *b_addr = &b_buffer_vnni_at(
                                    dims, b_buffer_vnni, k_h, k_w,
                                    k / B_MATRIX_BLOCK, n_final, 0);
                                __m512i bvec = _mm512_load_si512(b_addr);

                                cvec[ni * dims->m_accum + mi] =
                                    _mm512_dpbusd_epi32(
                                        cvec[ni * dims->m_accum + mi], avec,
                                        bvec);
                            }
                        }
                    }
                    int32_t *c_base =
                        &c_buffer_vnni[(m_final * dims->n_dim) + n_final];
                    _mm512_store_si512(c_base, cvec[ni * dims->m_accum + mi]);
                }
            }
        }
    }
    _mm_free(cvec);
}

bool init_data(const direct_conv_dims_t *dims)
{
    /*
     * sh and sw must be > 0.
     */

    if ((dims->sh == 0) || (dims->sw == 0))
        return false;

    /*
     * OUT_H(dims) and OUT_W(dims) must not be 0.
     */

    if ((OUT_H(dims) == 0) || (OUT_W(dims) == 0))
        return false;

    /*
     * N must be divisible by C_MATRIX_BLOCK
     */

    if ((dims->n_dim % C_MATRIX_BLOCK) != 0)
        return false;

    /*
     * N must be divisible by the number of N accumulators * C_MATRIX_BLOCK
     */

    if ((dims->n_dim % (dims->n_accum * C_MATRIX_BLOCK)) != 0)
        return false;

    /*
     * M (h_dim * w_dim) must be divisible by the number of M accumulators
     */

    if (((dims->h_dim * dims->w_dim) % dims->m_accum) != 0)
        return false;

    if (!allocate_buffers(dims))
        return false;

    populate_buffers(dims);
    relayout_a(dims);
    relayout_b(dims);

    return true;
}

void free_data(void)
{
    _mm_free(c_buffer_vnni);
    c_buffer_vnni = NULL;

    free(c_buffer);
    c_buffer = NULL;

    _mm_free(b_buffer_vnni);
    b_buffer_vnni = NULL;

    free(b_buffer);
    b_buffer = NULL;

    _mm_free(a_buffer_vnni);
    a_buffer_vnni = NULL;

    free(a_buffer);
    a_buffer = NULL;
}
