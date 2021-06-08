# Intel® 64 and IA-32 Architectures Optimization Reference Manual Code Samples

This repository contains buildable versions of the example source files in the
Intel Optimization Manual available here
(https://software.intel.com/en-us/articles/intel-sdm).  Assembly source code
is provided for GCC, Clang and MSVC, using the Intel syntax.  Unit tests are
also provided for each of the samples.

## Building on Linux

To run the unit tests

1. cd to the root folder of this project
2. mkdir build
3. cd build
4. cmake ..
5. make && make test

GCC 8.1 or higher is required to build the unit tests.  The unit tests are
compiled with --march=haswell and so a Haswell CPU or later is required to run
them.  Tests that execute instructions not present on Haswell will be
skipped if the CPU on which they are run does not support those instructions.

The code samples can also be compiled with clang:

1. cd to the root folder of this project
2. mkdir clang-build
3. cd clang-build
4. CC=clang CXX=clang++ cmake ..
5. make && make test


## Building on Windows

To run the tests on Windows machine-
Dependency- Visual Studio 2019

1. go to optimization repo on your local machine.
2. mkdir bld
3. cd bld
4. (inside x64 Native tools command prompt)
   "cmake -G "Visual Studio 16 2019" .." => this will generate visual studio solution files.
   open optimization.sln file using visual studio.
5. To Build- build "ALL_BUILD" project
6. To Run tests- build "RUN_TESTS" project.

## CPU Requirements

The code samples assume that they are being run on a Haswell processor
or later and do not perform runtime checks for the instructions that
they use that are present in Haswell, for example, FMA or AVX-2.
Some of the code samples may then crash if they are run
on a device that does not support these instructions.

The code samples do however check for post Haswell instruction sets such as AVX-512 and VNNI
before running.  Tests will skip if they detect that the post Haswell instructions
they need are not present.   Some of the newest examples use new instructions only found
in SkylakeX or later processors.  If you have an older CPU
in your PC you may find that everything builds on your system
but that some of the tests are skipped or crash (if you don't have AVX2) when run. In this case,
to fully run the tests, you need to run them under the SDE.

https://software.intel.com/en-us/articles/intel-software-development-emulator


## Code Sample Constraints

Many of the code samples in the Optimization Manual are code snippets.
They contain the minimum amount of code needed to illustrate a particular
concept that is discussed in the manual.  The code samples typically make
assumptions about the data they process.  These assumptions are often
not documented in the manual.  They are however documented in this
repository.  Each code sample is implemented as a function and each
of these functions is accompanied by a wrapper function that documents
and enforces the assumptions of the code sample.  For example, for two
functions are defined for Chapter 18 example 22

```
void lookup128_novbmi(const uint8_t *in, uint8_t *dict, uint8_t *out,
		      size_t len);
bool lookup128_novbmi_check(const uint8_t *in, uint8_t *dict, uint8_t *out,
			    size_t len);
```

lookup128_novbmi corresponds to the code in the Optimization Manual and
lookup128_novbmi_check is a wrapper function that checks the validity of
its parameters and then calls lookup128_novbmi.  The code for
lookup128_novbmi_check is as follows.

```
bool lookup128_novbmi_check(const uint8_t *in, uint8_t *dict, uint8_t *out,
			    size_t len)
{
	/*
	 * in, dict and out must be non-NULL.  dict must contain at least 128
	 * bytes.
	 */

	if (!in || !dict || !out)
		return false;

	/*
	 * len must be > 0 and a multiple of 32.
	 */

	if (len == 0 || len % 32 != 0)
		return false;

	lookup128_novbmi(in, dict, out, len);

	return true;
}
```

Note how the input constraints are documented and, where possible, enforced.


## Register usage

Assembly language code samples in the .s files, that are designed to be
compiled by gcc or clang on Linux, contain almost exact copies of the
code snippets that appear in the manual.  The core of these functions
use the same set of registers as used by the corresponding examples in
the manual.  Sometimes these code samples in the repository contain
some additional setup code that ensures that the registers are set up
in the way that the code snippets in the manual expect.  This setup
code is kept to a minimum by carefully choosing the order of the
parameters in the prototypes for the code samples.  This is why the
ordering of the parameters may seem a bit weird and inconsistent from
one example to the next.  As the MASM versions of the code samples in
the .asm files use the same prototypes as the samples in the .s files
and as Windows has a different calling convention to Linux, large
amounts of setup code would need to appear in the .asm files for the
MASM versions of the code samples to use the same set of registers
that are used by the code snippets in the manual and the .s files.
Consequently, the MASM versions of the code samples, tend to use
different sets of registers to keep the setup code to a minimum.

