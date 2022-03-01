if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex8_ass mce_scalar.s mce_avx2.s mce_avx512.s)
elseif(MSVC)
set(avx512_ex8_ass mce_scalar.asm mce_avx2.asm mce_avx512.asm)
endif()
add_executable(avx512_ex8_tests ex8_test.cpp mce_scalar.c mce_avx2.c mce_avx512.c ${avx512_ex8_ass})
target_link_libraries(avx512_ex8_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex8_bench ex8_bench.cpp ${avx512_ex8_ass})
  target_link_libraries(avx512_ex8_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex8_test COMMAND avx512_ex8_tests)
