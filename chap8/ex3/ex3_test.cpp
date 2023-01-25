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

#include "gtest/gtest.h"

#include "direct_conv.h"
#include "optimisation_common.h"

TEST(vnni, direct_conv)
{
    if (!supports_avx512_clx())
        GTEST_SKIP_("AVX-512 VNNI not supported, skipping test");

    direct_conv_dims_t tests[] = {
        {34, 34, 32, 32, 3, 3, 1, 1, 2, 2}, {34, 34, 32, 32, 4, 3, 1, 1, 2, 2},
        {34, 34, 32, 32, 3, 4, 1, 1, 2, 2}, {34, 34, 32, 32, 5, 5, 1, 1, 2, 2},
        {34, 34, 32, 64, 3, 3, 1, 1, 4, 4}, {34, 34, 32, 32, 3, 3, 2, 2, 2, 2},
    };

    for (const direct_conv_dims_t &dims : tests) {
        ASSERT_EQ(init_data(&dims), true);

        direct_conv_ref(&dims, a_buffer, b_buffer, c_buffer);

        direct_conv_opt_scalar(&dims, a_buffer_vnni, b_buffer_vnni,
                               c_buffer_vnni);

        for (int n = 0; n < dims.n_dim; n++)
            for (int h = 0; h < OUT_H(&dims); h++)
                for (int w = 0; w < OUT_W(&dims); w++)
                    ASSERT_EQ(c_buffer_vnni_at(&dims, c_buffer_vnni, h, w, n),
                              c_buffer_at(&dims, c_buffer, n, h, w));

        memset(c_buffer_vnni, 0, C_SIZE(&dims));

        direct_conv_opt(&dims, a_buffer_vnni, b_buffer_vnni, c_buffer_vnni);

        for (int n = 0; n < dims.n_dim; n++)
            for (int h = 0; h < OUT_H(&dims); h++)
                for (int w = 0; w < OUT_W(&dims); w++)
                    ASSERT_EQ(c_buffer_vnni_at(&dims, c_buffer_vnni, h, w, n),
                              c_buffer_at(&dims, c_buffer, n, h, w));

        free_data();
    }

    direct_conv_dims_t bad_tests[] = {
        {34, 34, 32, 32, 3, 3, 0, 1, 2, 2},  {34, 34, 32, 32, 3, 3, 1, 0, 2, 2},
        {34, 34, 32, 32, 3, 3, 1, 1, 34, 2}, {34, 34, 32, 34, 3, 3, 1, 1, 2, 2},
        {34, 34, 32, 48, 3, 3, 1, 1, 2, 2},  {34, 34, 32, 48, 3, 3, 1, 1, 2, 6},
    };

    for (const direct_conv_dims_t &dims : bad_tests) {
        ASSERT_EQ(init_data(&dims), false);
    }
}
