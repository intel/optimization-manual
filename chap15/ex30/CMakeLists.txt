if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex30_ass sqrt_rsqrtps_taylor_sse.s sqrt_vrsqrtps_taylor_avx.s)
elseif(MSVC)
set(avx_ex30_ass sqrt_rsqrtps_taylor_sse.asm sqrt_vrsqrtps_taylor_avx.asm)
endif()
add_executable(avx_ex30_tests ex30_test.cpp sqrt_rsqrtps_taylor_sse.c sqrt_vrsqrtps_taylor_avx.c ${avx_ex30_ass})
target_link_libraries(avx_ex30_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex30_bench ex30_bench.cpp ${avx_ex30_ass})
  target_link_libraries(avx_ex30_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex30_test COMMAND avx_ex30_tests)
