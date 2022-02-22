if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex29_ass sqrt_rsqrtps_sse.s sqrt_vrsqrtps_avx.s)
elseif(MSVC)
set(avx_ex29_ass sqrt_rsqrtps_sse.asm sqrt_vrsqrtps_avx.asm)
endif()
add_executable(avx_ex29_tests ex29_test.cpp sqrt_rsqrtps_sse.c sqrt_vrsqrtps_avx.c ${avx_ex29_ass})
target_link_libraries(avx_ex29_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex29_bench ex29_bench.cpp ${avx_ex29_ass})
  target_link_libraries(avx_ex29_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex29_test COMMAND avx_ex29_tests)
