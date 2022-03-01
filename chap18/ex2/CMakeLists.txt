if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex2_ass transform_avx.s transform_avx512.s)
elseif(MSVC)
set(avx512_ex2_ass transform_avx.asm transform_avx512.asm)
endif()

add_executable(avx512_ex2_tests ex2_test.cpp transform_avx.c transform_avx512.c ${avx512_ex2_ass})

target_link_libraries(avx512_ex2_tests gtest_main optimisation_common)
IF( benchmark_FOUND )
  add_executable(avx512_ex2_bench ex2_bench.cpp ${avx512_ex2_ass})
  target_link_libraries(avx512_ex2_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex2_test COMMAND avx512_ex2_tests)
