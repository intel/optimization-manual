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

#include <immintrin.h>
#include <stdint.h>

#include "i64toa_avx2.h"

#ifndef _MSC_VER
#include <x86intrin.h>
#endif
#define QWCG10to8 0xabcc77118461cefdull

static int pr_cg_10to4[8] = {0x68db8db, 0, 0, 0, 0x68db8db, 0, 0, 0};
static int pr_1_m10to4[8] = {-10000, 0, 0, 0, 1, 0, 0, 0};

// clang-format off
#include "parmod10.h"
#include "ubsavx2.h"
#include "avx2i_q2a_u63b.h"

// clang-format on

char *i64toa_avx2i(int64_t xx, char *p)
{
	int cnt;

	_mm256_zeroupper();
	if (xx < 0)
		cnt = avx2i_q2a_u63b(-xx, p);
	else
		cnt = avx2i_q2a_u63b(xx, p);
	p[cnt] = 0;
	return p;
}

bool i64toa_avx2i_check(int64_t xx, char *p)
{
	/*
	 * p must be non-null and must be at least 21 bytes in length.
	 */

	if (!p)
		return false;

	(void)i64toa_avx2i(xx, p);

	return true;
}
