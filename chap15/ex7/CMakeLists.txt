if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex7_ass median_sse.s median_avx_overlap.s median_avx_vperm.s)
elseif(MSVC)
set(avx_ex7_ass median_sse.asm median_avx_overlap.asm median_avx_vperm.asm)
endif()
add_executable(avx_ex7_tests ex7_test.cpp median_sse.c median_avx_overlap.c median_avx_vperm.c ${avx_ex7_ass})
target_link_libraries(avx_ex7_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex7_bench ex7_bench.cpp ${avx_ex7_ass})
  target_link_libraries(avx_ex7_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex7_test COMMAND avx_ex7_tests)
