if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex18_ass three_tap_mixed_avx.s)
elseif(MSVC)
set(avx_ex18_ass three_tap_mixed_avx.asm)
endif()
add_executable(avx_ex18_tests ex18_test.cpp three_tap_mixed_avx.c ${avx_ex18_ass})
target_link_libraries(avx_ex18_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex18_bench ex18_bench.cpp ${avx_ex18_ass})
  target_link_libraries(avx_ex18_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex18_test COMMAND avx_ex18_tests)
