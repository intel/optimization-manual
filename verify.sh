#!/bin/bash

set -e
./check-format.sh
if [ ! -f checkpatch.pl ]; then
    wget https://raw.githubusercontent.com/torvalds/linux/v5.11/scripts/checkpatch.pl
fi
if [ ! -f spelling.txt ]; then  
    wget https://raw.githubusercontent.com/torvalds/linux/v5.11/scripts/spelling.txt
fi
if [ ! -f const_structs.checkpatch ]; then  
    wget https://raw.githubusercontent.com/torvalds/linux/v5.11/scripts/const_structs.checkpatch
fi
find . \( -path './build' \) -prune -type f -o -name '*.cpp' -o -name "*.c" -o -name "*.h" | xargs perl checkpatch.pl --no-tree -f --strict --show-types --ignore NEW_TYPEDEFS --ignore PREFER_KERNEL_TYPES --ignore SPLIT_STRING --ignore UNNECESSARY_PARENTHESES --ignore SPDX_LICENSE_TAG --ignore OPEN_ENDED_LINE --ignore BOOL_MEMBER --ignore MACRO_ARG_REUSE --ignore PREFER_ALIGNED --ignore CAMELCASE --ignore PREFER_DEFINED_ATTRIBUTE_MACRO --ignore SPACING --ignore BIT_MACRO
mkdir -p build
cd build
cmake .. -DENABLE_WERROR=ON
make -j && make test
cd ..
