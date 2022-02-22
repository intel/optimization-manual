if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex6_ass mask_avx512.s blend_avx512.s)
elseif(MSVC)
set(avx512_ex6_ass mask_avx512.asm blend_avx512.asm)
endif()

add_executable(avx512_ex6_tests ex6_test.cpp mask_avx512.c blend_avx512.c ${avx512_ex6_ass})
target_link_libraries(avx512_ex6_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex6_bench ex6_bench.cpp ${avx512_ex6_ass})
  target_link_libraries(avx512_ex6_bench benchmark::benchmark optimisation_common)
ENDIF()
add_test(NAME avx512_ex6_test COMMAND avx512_ex6_tests)
