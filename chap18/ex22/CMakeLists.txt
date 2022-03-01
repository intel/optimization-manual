if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex22_ass lookup128_novbmi.s lookup128_vbmi.s)
elseif(MSVC)
set(avx512_ex22_ass lookup128_novbmi.asm lookup128_vbmi.asm)
endif()
add_executable(avx512_ex22_tests ex22_test.cpp lookup128_novbmi.c lookup128_vbmi.c ${avx512_ex22_ass})
target_link_libraries(avx512_ex22_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex22_bench ex22_bench.cpp ${avx512_ex22_ass})
  target_link_libraries(avx512_ex22_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex22_test COMMAND avx512_ex22_tests)
