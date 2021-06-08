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

#include "gtest/gtest.h"

#include <string.h>

#include "pixel_shuffler.hpp"

#define INPUT_BATCH 2
#define INPUT_CHANNELS 16
#define INPUT_HEIGHT 32
#define INPUT_WIDTH 64

/*
 * Another valid set of input parameters which are useful for testing
 * and debugging as they matrices involved are smaller.
 *
 * #define INPUT_BATCH 2
 * #define INPUT_CHANNELS 4
 * #define INPUT_HEIGHT 4
 * #define INPUT_WIDTH 4
 */

#define OUTPUT_BATCH INPUT_BATCH
#define OUTPUT_CHANNELS (INPUT_CHANNELS / 4)
#define OUTPUT_HEIGHT (INPUT_HEIGHT * 2)
#define OUTPUT_WIDTH (INPUT_WIDTH * 2)

static pstype input[INPUT_BATCH * INPUT_CHANNELS * INPUT_HEIGHT * INPUT_WIDTH];
static pstype
    output[OUTPUT_BATCH * OUTPUT_CHANNELS * OUTPUT_HEIGHT * OUTPUT_WIDTH];

void init_data()
{
	size_t i = 0;
	for (size_t f = 0; f < INPUT_BATCH; f++)
		for (size_t c = 0; c < INPUT_CHANNELS; c++)
			for (size_t h = 0; h < INPUT_HEIGHT; h++)
				for (size_t w = 0; w < INPUT_WIDTH; w++)
					input[i++] = (pstype)(
					    (f * INPUT_CHANNELS * INPUT_WIDTH *
					     INPUT_HEIGHT) +
					    (c * INPUT_WIDTH * INPUT_HEIGHT) +
					    (h * INPUT_WIDTH) + w);

	memset(output, 0, sizeof(output));
}

TEST(vnni, pixel_shuffler_test)
{
	std::vector<int> bottom_shape = {INPUT_BATCH, INPUT_CHANNELS,
					 INPUT_HEIGHT, INPUT_WIDTH};
	std::vector<int> top_shape = {OUTPUT_BATCH, OUTPUT_CHANNELS,
				      OUTPUT_HEIGHT, OUTPUT_WIDTH};
	init_data();

	pixel_shuffler(bottom_shape, top_shape, &input[0], &output[0]);

	size_t input_index;
	size_t i = 0;
	for (size_t f = 0; f < OUTPUT_BATCH; f++)
		for (size_t c = 0; c < OUTPUT_CHANNELS; c++)
			for (size_t h = 0; h < OUTPUT_HEIGHT; h++)
				for (size_t w = 0; w < OUTPUT_WIDTH; w++) {
					input_index =
					    f * (INPUT_CHANNELS * INPUT_HEIGHT *
						 INPUT_WIDTH);
					input_index +=
					    ((w & 1) + ((h & 1) * 2)) *
					    (INPUT_HEIGHT * INPUT_WIDTH);
					input_index += (h / 2) * INPUT_WIDTH;
					input_index += w / 2;
					ASSERT_EQ(output[i++],
						  input[input_index]);
				}
}
