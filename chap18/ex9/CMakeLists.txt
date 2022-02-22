if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex9_ass no_peeling.s peeling.s)
elseif(MSVC)
set(avx512_ex9_ass no_peeling.asm peeling.asm)
endif()
add_executable(avx512_ex9_tests ex9_test.cpp no_peeling.c peeling.c ${avx512_ex9_ass})
target_link_libraries(avx512_ex9_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex9_bench ex9_bench.cpp ${avx512_ex9_ass})
  target_link_libraries(avx512_ex9_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex9_test COMMAND avx512_ex9_tests)
