if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex24_ass only_256bit.s both_256_512bit.s)
elseif(MSVC)
set(avx512_ex24_ass only_256bit.asm both_256_512bit.asm)
endif()
add_executable(avx512_ex24_tests ex24_test.cpp ${avx512_ex24_ass})
target_link_libraries(avx512_ex24_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex24_bench ex24_bench.cpp ${avx512_ex24_ass})
  target_link_libraries(avx512_ex24_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex24_test COMMAND avx512_ex24_tests)
