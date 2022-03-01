if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE mul_blend_avx512.c APPEND PROPERTY COMPILE_OPTIONS "-mavx512f")
endif()
set(avx512_ex3_srcs mul_blend_avx.c mul_blend_avx512.c)

add_executable(avx512_ex3_tests ex3_test.cpp ${avx512_ex3_srcs})
target_link_libraries(avx512_ex3_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex3_bench ex3_bench.cpp ${avx512_ex3_srcs})
  target_link_libraries(avx512_ex3_bench benchmark::benchmark optimisation_common)
ENDIF()
add_test(NAME avx512_ex3_test COMMAND avx512_ex3_tests)
