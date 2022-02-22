set(avx_ex1_srcs transform_sse.c transform_avx.c)
add_executable(avx_ex1_tests ex1_test.cpp ${avx_ex1_srcs})
target_link_libraries(avx_ex1_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex1_bench ex1_bench.cpp ${avx_ex1_srcs})
  target_link_libraries(avx_ex1_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex1_test COMMAND avx_ex1_tests)
