if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex12_ass ternary_avx2.s ternary_avx512.s ternary_vpternlog.s)
elseif(MSVC)
set(avx512_ex12_ass ternary_avx2.asm ternary_avx512.asm ternary_vpternlog.asm)
endif()
add_executable(avx512_ex12_tests ex12_test.cpp ${avx512_ex12_ass})
target_link_libraries(avx512_ex12_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex12_bench ex12_bench.cpp ${avx512_ex12_ass})
  target_link_libraries(avx512_ex12_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex12_test COMMAND avx512_ex12_tests)
