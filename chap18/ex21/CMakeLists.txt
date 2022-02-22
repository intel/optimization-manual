if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex21_ass lookup_novbmi.s lookup_vbmi.s)
elseif(MSVC)
set(avx512_ex21_ass lookup_novbmi.asm lookup_vbmi.asm)
endif()
add_executable(avx512_ex21_tests ex21_test.cpp lookup_novbmi.c lookup_vbmi.c ${avx512_ex21_ass})
target_link_libraries(avx512_ex21_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex21_bench ex21_bench.cpp ${avx512_ex21_ass})
  target_link_libraries(avx512_ex21_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex21_test COMMAND avx512_ex21_tests)
