if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex35_ass fp_mul_add.s fp_fma.s)
elseif(MSVC)
set(avx_ex35_ass fp_mul_add.asm fp_fma.asm)
endif()
add_executable(avx_ex35_tests ex35_test.cpp fp_mul_add.c fp_fma.c ${avx_ex35_ass})
target_link_libraries(avx_ex35_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex35_bench ex35_bench.cpp ${avx_ex35_ass})
  target_link_libraries(avx_ex35_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex35_test COMMAND avx_ex35_tests)
