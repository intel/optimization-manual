if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex8_ass gather_scalar.s gather_vinsert.s gather_vinsert_vshufps.s)
elseif(MSVC)
set(avx_ex8_ass gather_scalar.asm gather_vinsert.asm gather_vinsert_vshufps.asm)
endif()
add_executable(avx_ex8_tests ex8_test.cpp gather_scalar.c gather_vinsert.c gather_vinsert_vshufps.c ${avx_ex8_ass})
target_link_libraries(avx_ex8_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex8_bench ex8_bench.cpp ${avx_ex8_ass})
  target_link_libraries(avx_ex8_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex8_test COMMAND avx_ex8_tests)
