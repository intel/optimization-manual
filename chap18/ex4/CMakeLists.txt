if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex4_ass mul_blend_avx.s mul_blend_avx512.s)
elseif(MSVC)
set(avx512_ex4_ass mul_blend_avx.asm mul_blend_avx512.asm)
endif()

add_executable(avx512_ex4_tests ex4_test.cpp mul_blend_avx.c mul_blend_avx512.c ${avx512_ex4_ass})
target_link_libraries(avx512_ex4_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex4_bench ex4_bench.cpp ${avx512_ex4_ass})
  target_link_libraries(avx512_ex4_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex4_test COMMAND avx512_ex4_tests)
