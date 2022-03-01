if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex28_ass sqrtps_sse.s vsqrtps_avx.s)
elseif(MSVC)
set(avx_ex28_ass sqrtps_sse.asm vsqrtps_avx.asm)
endif()
add_executable(avx_ex28_tests ex28_test.cpp sqrtps_sse.c vsqrtps_avx.c ${avx_ex28_ass})

IF( benchmark_FOUND )
  add_executable(avx_ex28_bench ex28_bench.cpp ${avx_ex28_ass})
  target_link_libraries(avx_ex28_bench benchmark::benchmark)
ENDIF()

target_link_libraries(avx_ex28_tests gtest_main)
add_test(NAME avx_ex28_test COMMAND avx_ex28_tests)
