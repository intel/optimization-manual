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

#ifndef VERTEX_STRUCT_H__
#define VERTEX_STRUCT_H__

#include <stddef.h>

#define MAX_SIZE 4

typedef struct _VERTEX_AOS {
	float x, y, z, color;
} Vertex_aos; // AoS structure declaration

typedef struct _VERTEX_SOA {
	float x[MAX_SIZE], y[MAX_SIZE], z[MAX_SIZE], color[MAX_SIZE];
} Vertex_soa; // SoA structure declaration
#endif
