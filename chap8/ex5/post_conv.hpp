/*
 * Copyright (C) 2021 by Intel Corporation
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

#ifndef POST_CONV_HPP_
#define POST_CONV_HPP_

#include <immintrin.h>
#include <stdint.h>

void init_data(float *bias, float *dqfs, int8_t *dest, int8_t *dest_scalar,
	       __m512i *out_reg);
void basic_post_conv(uint32_t *output, int8_t *outputFeatureMaps,
		     size_t OFMChannelOffset, size_t offset, float *bias,
		     float *dqfs);
void post_conv_scalar(uint32_t *output, int8_t *outputFeatureMaps,
		      size_t OFMChannelOffset, size_t offset, float *bias,
		      float *dqfs, int8_t *dest_scalar);

#endif
