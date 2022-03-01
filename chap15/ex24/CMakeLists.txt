if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex24_ass rcpps_mul_sse.s vrcpps_mul_avx.s)
elseif(MSVC)
set(avx_ex24_ass rcpps_mul_sse.asm vrcpps_mul_avx.asm)
endif()
add_executable(avx_ex24_tests ex24_test.cpp rcpps_mul_sse.c vrcpps_mul_avx.c ${avx_ex24_ass})
target_link_libraries(avx_ex24_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex24_bench ex24_bench.cpp ${avx_ex24_ass})
  target_link_libraries(avx_ex24_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex24_test COMMAND avx_ex24_tests)
