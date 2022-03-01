if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex19_ass scalar_histogram.s avx512_histogram.s)
elseif(MSVC)
set(avx512_ex19_ass scalar_histogram.asm avx512_histogram.asm)
endif()
add_executable(avx512_ex19_tests ex19_test.cpp scalar_histogram.c avx512_histogram.c ${avx512_ex19_ass})
target_link_libraries(avx512_ex19_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex19_bench ex19_bench.cpp ${avx512_ex19_ass})
  target_link_libraries(avx512_ex19_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex19_test COMMAND avx512_ex19_tests)
