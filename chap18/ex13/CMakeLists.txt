if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex13_ass transpose_scalar.s transpose_avx2.s transpose_avx512.s)
elseif(MSVC)
set(avx512_ex13_ass transpose_scalar.asm transpose_avx2.asm transpose_avx512.asm)
endif()
add_executable(avx512_ex13_tests ex13_test.cpp transpose_scalar.c transpose_avx2.c transpose_avx512.c ${avx512_ex13_ass})
target_link_libraries(avx512_ex13_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex13_bench ex13_bench.cpp ${avx512_ex13_ass})
  target_link_libraries(avx512_ex13_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex13_test COMMAND avx512_ex13_tests)
