if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex36_ass no_unroll_reduce.s unroll_reduce.s)
elseif(MSVC)
set(avx_ex36_ass no_unroll_reduce.asm unroll_reduce.asm)
endif()
add_executable(avx_ex36_tests ex36_test.cpp no_unroll_reduce.c unroll_reduce.c ${avx_ex36_ass})
target_link_libraries(avx_ex36_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex36_bench ex36_bench.cpp ${avx_ex36_ass})
  target_link_libraries(avx_ex36_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex36_test COMMAND avx_ex36_tests)
