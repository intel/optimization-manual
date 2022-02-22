if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex27_ass rsqrtps_newt_sse.s vrsqrtps_newt_avx.s)
elseif(MSVC)
set(avx_ex27_ass rsqrtps_newt_sse.asm vrsqrtps_newt_avx.asm)
endif()
add_executable(avx_ex27_tests ex27_test.cpp rsqrtps_newt_sse.c vrsqrtps_newt_avx.c ${avx_ex27_ass})
target_link_libraries(avx_ex27_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex27_bench ex27_bench.cpp ${avx_ex27_ass})
  target_link_libraries(avx_ex27_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex27_test COMMAND avx_ex27_tests)
