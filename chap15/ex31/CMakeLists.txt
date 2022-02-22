if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex31_ass subsum_avx.s subsum_sse.s)
elseif(MSVC)
set(avx_ex31_ass subsum_avx.asm subsum_sse.asm)
endif()
add_executable(avx_ex31_tests ex31_test.cpp subsum_avx.c subsum_sse.c ${avx_ex31_ass})
target_link_libraries(avx_ex31_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex31_bench ex31_bench.cpp ${avx_ex31_ass})
  target_link_libraries(avx_ex31_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex31_test COMMAND avx_ex31_tests)
