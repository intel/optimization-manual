if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex22_ass divps_sse.s vdivps_avx.s)
elseif(MSVC)
set(avx_ex22_ass divps_sse.asm vdivps_avx.asm)
endif()
add_executable(avx_ex22_tests ex22_test.cpp divps_sse.c vdivps_avx.c ${avx_ex22_ass})
target_link_libraries(avx_ex22_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex22_bench ex22_bench.cpp ${avx_ex22_ass})
  target_link_libraries(avx_ex22_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex22_test COMMAND avx_ex22_tests)
