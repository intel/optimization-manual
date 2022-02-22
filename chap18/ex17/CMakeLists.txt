if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex17_ass scalar_scatter.s software_scatter.s hardware_scatter.s)
elseif(MSVC)
set(avx512_ex17_ass scalar_scatter.asm software_scatter.asm hardware_scatter.asm)
endif()
add_executable(avx512_ex17_tests ex17_test.cpp scalar_scatter.c software_scatter.c hardware_scatter.c ${avx512_ex17_ass})
target_link_libraries(avx512_ex17_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex17_bench ex17_bench.cpp ${avx512_ex17_ass})
  target_link_libraries(avx512_ex17_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex17_test COMMAND avx512_ex17_tests)
