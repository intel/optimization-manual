if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex9_ass scatter_scalar.s scatter_avx.s)
elseif(MSVC)
set(avx_ex9_ass scatter_scalar.asm scatter_avx.asm)
endif()
add_executable(avx_ex9_tests ex9_test.cpp scatter_scalar.c scatter_avx.c ${avx_ex9_ass})
target_link_libraries(avx_ex9_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex9_bench ex9_bench.cpp ${avx_ex9_ass})
  target_link_libraries(avx_ex9_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex9_test COMMAND avx_ex9_tests)
