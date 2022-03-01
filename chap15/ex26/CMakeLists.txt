if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex26_ass rsqrtps_sse.s vrsqrtps_avx.s)
elseif(MSVC)
set(avx_ex26_ass rsqrtps_sse.asm vrsqrtps_avx.asm)
endif()
add_executable(avx_ex26_tests ex26_test.cpp rsqrtps_sse.c vrsqrtps_avx.c ${avx_ex26_ass})

IF( benchmark_FOUND )
  add_executable(avx_ex26_bench ex26_bench.cpp ${avx_ex26_ass})
  target_link_libraries(avx_ex26_bench benchmark::benchmark)
ENDIF()

target_link_libraries(avx_ex26_tests gtest_main)
add_test(NAME avx_ex26_test COMMAND avx_ex26_tests)
