#!/bin/bash

set -e
clang-format --version
for i in `find . -name '*.cpp' -o -name "*.c" -o -name "*.h" | grep -v build `; do
    echo "Checking format of $i"
    clang-format -style=file $i | diff $i -
done
