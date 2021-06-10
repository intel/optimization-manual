# Contributing to the Intel® 64 and IA-32 Architectures Optimization Reference Manual Code Samples

Intel® 64 and IA-32 Architectures Optimization Reference Manual Code Samples is an open source project licensed under the [0 Clause BSD License](https://github.com/intel/optimization-manual/blob/main/COPYING)

## Coding Style

All C code in the Intel® 64 and IA-32 Architectures Optimization
Reference Manual Code Samples follows the [Linux kernel Coding Style](https://www.kernel.org/doc/html/v5.11/process/coding-style.html),
with some
[exceptions](https://github.com/intel/optimization-manual/blob/main/verify.sh#L14).
All C and C++ code is formatted using clang-format version 11 using
these
[settings](https://github.com/intel/optimization-manual/blob/main/.clang-format).
All assembly language code follows the Intel syntax.  Some of these
coding conventions are enforced by the CI.

## Certificate of Origin

In order to get a clear contribution chain of trust we use the [signed-off-by language](https://01.org/community/signed-process)
used by the Linux kernel project.

## Patch format

Beside the signed-off-by footer, we expect each patch to comply with the following format:

```
Change summary

More detailed explanation of your changes: Why and how.
Wrap it to 72 characters.

Fixes #NUMBER (or URL to the issue)

Signed-off-by: <contributor@foo.com>
```

For example:

```
Fix poorly named identifiers

One identifier, FnName, in func.s was poorly named.  It has been renamed
to fn_name.  Another identifier retval was not needed and has been removed
entirely.

Fixes #1

Signed-off-by: Mark Ryan <mark.d.ryan@intel.com>
```

## New files

Each new source file in the Intel® 64 and IA-32 Architectures
Optimization Reference Manual Code Samples must contain a version of the
following header that uses the appropriate comment syntax for the
source file:

```
/*
 * Copyright contributors to the Intel® 64 and IA-32 Architectures Optimization
 * Reference Manual Code Samples project
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
```

## Contributors File

The [CONTRIBUTORS.md](https://github.com/intel/optimization-manual/blob/main/CONTRIBUTORS.md)
file is a partial list of contributors to the
Intel® 64 and IA-32 Architectures Optimization Reference Manual Code Samples.
To see the full list of contributors, see the revision history in source control.

Contributors who wish to be recognized in this file should add
themselves (or their employer, as appropriate).

## Pull requests

We accept github pull requests.

## Issue tracking

If you have a problem, please let us know.  If it's a bug not already documented, by all means please [open an
issue in github](https://github.com/intel/optimization-manual/issues).

Any security issues discovered with this repository should be reported by following the instructions on https://01.org/security.