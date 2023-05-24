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

#ifndef DIRECT_CONV_H
#define DIRECT_CONV_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct direct_conv_dims_t {
    // problem params
    int h_dim; // height of inputs
    int w_dim; // width of inputs
    int k_dim; // number of IFMS
    int n_dim; // number of OFMS
    int kh;    // kernel height
    int kw;    // kernel width
    int sh;    // stride height
    int sw;    // stride width

    // blocking params
    int n_accum;
    int m_accum;
};

typedef struct direct_conv_dims_t direct_conv_dims_t;

#define B_MATRIX_BLOCK 4
#define C_MATRIX_BLOCK 16
#define CACHE_LINE_SIZE 64

#define OUT_H(d) (((d)->h_dim - (d)->kh) / (d)->sh + 1)
#define OUT_W(d) (((d)->w_dim - (d)->kw) / (d)->sw + 1)

#define A_SIZE(d) ((d)->k_dim * (d)->h_dim * (d)->w_dim)
#define B_SIZE(d) ((d)->n_dim * (d)->k_dim * (d)->kh * (d)->kw)
#define C_SIZE(d) (OUT_H(d) * OUT_W(d) * (d)->n_dim * sizeof(int32_t))

#define a_buffer_at(d, a, k, h, w)                                             \
    (a[((k) * (d)->h_dim * (d)->w_dim) + ((h) * (d)->w_dim) + (w)])
#define a_buffer_vnni_at(d, a, h, w, k)                                        \
    (a[((h) * (d)->w_dim * (d)->k_dim) + ((w) * (d)->k_dim) + (k)])
#define b_buffer_at(d, b, k, n, k_h, k_w)                                      \
    (b[((k) * (d)->n_dim * (d)->kh * (d)->kw) + ((n) * (d)->kh * (d)->kw) +    \
       ((k_h) * (d)->kw) + (k_w)])

#define b_buffer_vnni_at(d, b, k_h, k_w, k_d, n, k_m)                          \
    (b[((k_h) * (d)->kw * ((d)->k_dim / B_MATRIX_BLOCK) * (d)->n_dim *         \
        B_MATRIX_BLOCK) +                                                      \
       ((k_w) * ((d)->k_dim / B_MATRIX_BLOCK) * (d)->n_dim * B_MATRIX_BLOCK) + \
       ((k_d) * (d)->n_dim * B_MATRIX_BLOCK) + ((n)*B_MATRIX_BLOCK) + (k_m)])
#define c_buffer_at(d, c, n, h, w)                                             \
    (c[((n)*OUT_H(d) * OUT_W(d)) + ((h)*OUT_W(d)) + (w)])
#define c_buffer_vnni_at(d, c, h, w, n)                                        \
    (c[((h)*OUT_W(d) * (d)->n_dim) + ((w) * (d)->n_dim) + (n)])

// buffers
extern char *a_buffer;
extern char *a_buffer_vnni;
extern char *b_buffer;
extern char *b_buffer_vnni;
extern int32_t *c_buffer;
extern int32_t *c_buffer_vnni;

bool init_data(const direct_conv_dims_t *dims);
void free_data(void);
void direct_conv_ref(const direct_conv_dims_t *dims, const char *a_buffer,
                     const char *b_buffer, int32_t *c_buffer);
void direct_conv_opt(const direct_conv_dims_t *dims, const char *a_buffer_vnni,
                     const char *b_buffer_vnni, int32_t *c_buffer_vnni);
void direct_conv_opt_scalar(const direct_conv_dims_t *dims,
                            const char *a_buffer_vnni,
                            const char *b_buffer_vnni, int32_t *c_buffer_vnni);

#ifdef __cplusplus
}
#endif

#endif
