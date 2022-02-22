if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE transform_avx512.c APPEND PROPERTY COMPILE_OPTIONS "-mavx512f")
endif()
set(avx512_ex1_srcs transform_avx.c transform_avx512.c)
add_executable(avx512_ex1_tests ex1_test.cpp ${avx512_ex1_srcs})
target_link_libraries(avx512_ex1_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex1_bench ex1_bench.cpp ${avx512_ex1_srcs})
  target_link_libraries(avx512_ex1_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex1_test COMMAND avx512_ex1_tests)
