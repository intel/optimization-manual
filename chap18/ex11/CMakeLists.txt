if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex11_ass expand_scalar.s expand_avx2.s expand_avx512.s)
elseif(MSVC)
set(avx512_ex11_ass expand_scalar.asm expand_avx2.asm expand_avx512.asm)
endif()
add_executable(avx512_ex11_tests ex11_test.cpp expand_scalar.c expand_avx2.c expand_avx512.c ${avx512_ex11_ass})
target_link_libraries(avx512_ex11_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex11_bench ex11_bench.cpp ${avx512_ex11_ass})
  target_link_libraries(avx512_ex11_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex11_test COMMAND avx512_ex11_tests)
