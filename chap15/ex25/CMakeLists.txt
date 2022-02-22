if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex25_ass sqrtps_divps_sse.s vsqrtps_vdivps_avx.s)
elseif(MSVC)
set(avx_ex25_ass sqrtps_divps_sse.asm vsqrtps_vdivps_avx.asm)
endif()
add_executable(avx_ex25_tests ex25_test.cpp sqrtps_divps_sse.c vsqrtps_vdivps_avx.c ${avx_ex25_ass})
target_link_libraries(avx_ex25_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex25_bench ex25_bench.cpp ${avx_ex25_ass})
  target_link_libraries(avx_ex25_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex25_test COMMAND avx_ex25_tests)
