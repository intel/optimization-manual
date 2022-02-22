if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex16_ass three_tap_sse.s)
elseif(MSVC)
set(avx_ex16_ass three_tap_sse.asm)
endif()
add_executable(avx_ex16_tests ex16_test.cpp three_tap_sse.c ${avx_ex16_ass})
target_link_libraries(avx_ex16_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex16_bench ex16_bench.cpp ${avx_ex16_ass})
  target_link_libraries(avx_ex16_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex16_test COMMAND avx_ex16_tests)
