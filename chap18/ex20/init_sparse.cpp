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

#include "init_sparse.h"
#include <algorithm>

void init_sparse(uint32_t *a_index, double *a_values, uint32_t *b_index,
		 double *b_values, size_t len)
{
	size_t max_size = len * 4;

	for (size_t i = 0; i < max_size; i++) {
		a_index[i] = (uint32_t)i;
		b_index[i] = (uint32_t)i;
	}

	for (size_t i = 0; i < len; i++) {
		a_values[i] = (((double)rand()) / RAND_MAX) - 0.5;
		b_values[i] = (((double)rand()) / RAND_MAX) - 0.5;
	}

	for (size_t i = 0; i < max_size; i++) {
		size_t a = rand() % max_size;
		size_t b = rand() % max_size;
		uint32_t tmp;

		tmp = a_index[a];
		a_index[a] = a_index[b];
		a_index[b] = tmp;

		a = rand() % max_size;
		b = rand() % max_size;

		tmp = b_index[a];
		b_index[a] = b_index[b];
		b_index[b] = tmp;
	}

	std::sort(&a_index[0], &a_index[len]);
	std::sort(&b_index[0], &b_index[len]);
}
