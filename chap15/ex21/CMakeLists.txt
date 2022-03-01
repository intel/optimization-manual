if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex21_ass mul_cpx_reg.s mul_cpx_mem.s)
elseif(MSVC)
set(avx_ex21_ass mul_cpx_reg.asm mul_cpx_mem.asm)
endif()
add_executable(avx_ex21_tests ex21_test.cpp mul_cpx_reg.c mul_cpx_mem.c ${avx_ex21_ass})
target_link_libraries(avx_ex21_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex21_bench ex21_bench.cpp ${avx_ex21_ass})
  target_link_libraries(avx_ex21_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex21_test COMMAND avx_ex21_tests)
