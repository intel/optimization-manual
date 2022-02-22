if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex26_ass g2s_vpgatherdd.s g2s_vpermi2d.s)
elseif(MSVC)
set(avx512_ex26_ass g2s_vpgatherdd.asm g2s_vpermi2d.asm)
endif()
add_executable(avx512_ex26_tests ex26_test.cpp g2s_vpgatherdd.c g2s_vpermi2d.c ${avx512_ex26_ass})
target_link_libraries(avx512_ex26_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex26_bench ex26_bench.cpp ${avx512_ex26_ass})
  target_link_libraries(avx512_ex26_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex26_test COMMAND avx512_ex26_tests)
