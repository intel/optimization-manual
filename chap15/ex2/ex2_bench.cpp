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

#include <benchmark/benchmark.h>
#include <xmmintrin.h>

#include "transform_avx.h"
#include "transform_sse.h"

static void BM_transform_sse(benchmark::State &state)
{
	int len = state.range(0);

	// Dynamic memory allocation with 16byte
	// alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 16);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 16);
	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;
	float cos_teta = 0.8660254037f;
	float sin_teta = 0.5f;

	// clang-format off

	// Static memory allocation of 4 floats with 16byte alignment
#ifdef _MSC_VER // Preferred VS2019 version 16.3 or higher
	__declspec(align(16)) float cos_sin_teta_vec[4] = {
		cos_teta, sin_teta, cos_teta, sin_teta};
	__declspec(align(16)) float sin_cos_teta_vec[4] = {
		sin_teta, cos_teta, sin_teta, cos_teta};
#else
	float cos_sin_teta_vec[4] __attribute__((aligned(16))) = {
		cos_teta, sin_teta, cos_teta, sin_teta};
	float sin_cos_teta_vec[4] __attribute__((aligned(16))) = {
		sin_teta, cos_teta, sin_teta, cos_teta};
#endif

	// clang-format on

	for (auto _ : state) {
		transform_sse(cos_sin_teta_vec, sin_cos_teta_vec, pInVector,
			      pOutVector, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(pInVector[0])));

	_mm_free(pInVector);
	_mm_free(pOutVector);
}
static void BM_transform_avx(benchmark::State &state)
{
	int len = state.range(0);
	// Dynamic memory allocation with 32byte alignment
	float *pInVector = (float *)_mm_malloc(len * sizeof(float), 32);
	float *pOutVector = (float *)_mm_malloc(len * sizeof(float), 32);

	// init data
	for (int i = 0; i < len; i++)
		pInVector[i] = 1;

	float cos_teta = 0.8660254037;
	float sin_teta = 0.5;

	// clang-format off

	//Static memory allocation of 8 floats with 32byte alignments
#ifdef _MSC_VER
	__declspec(align(32)) float cos_sin_teta_vec[8] = {
#else
	float cos_sin_teta_vec[8] __attribute__((aligned(32))) = {
#endif
            cos_teta, sin_teta, cos_teta, sin_teta,
            cos_teta, sin_teta, cos_teta, sin_teta
        };
#ifdef _MSC_VER
	__declspec(align(32)) float sin_cos_teta_vec[8] = {
#else
	float sin_cos_teta_vec[8] __attribute__((aligned(32))) = {
#endif
            sin_teta, cos_teta, sin_teta, cos_teta,
            sin_teta, cos_teta, sin_teta, cos_teta
        };

	// clang-format on

	for (auto _ : state) {
		transform_avx(cos_sin_teta_vec, sin_cos_teta_vec, pInVector,
			      pOutVector, len);
	}
	state.SetBytesProcessed(int64_t(state.iterations()) * int64_t(len) *
				int64_t(sizeof(pInVector[0])));

	_mm_free(pInVector);
	_mm_free(pOutVector);
}

BENCHMARK(BM_transform_sse)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK(BM_transform_avx)
    ->Arg(1 << 6)
    ->Arg(1 << 8)
    ->Arg(1 << 10)
    ->Arg(1 << 12)
    ->Arg(1 << 14)
    ->Arg(1 << 16)
    ->Arg(1 << 18);
BENCHMARK_MAIN();
