if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex19_ass vshufps_transpose.s vblendps_transpose.s)
elseif(MSVC)
set(avx_ex19_ass vshufps_transpose.asm vblendps_transpose.asm)
endif()
add_executable(avx_ex19_tests ex19_test.cpp vshufps_transpose.c vblendps_transpose.c ${avx_ex19_ass})

IF( benchmark_FOUND )
  add_executable(avx_ex19_bench ex19_bench.cpp ${avx_ex19_ass})
  target_link_libraries(avx_ex19_bench benchmark::benchmark)
ENDIF()

target_link_libraries(avx_ex19_tests gtest_main)
add_test(NAME avx_ex19_test COMMAND avx_ex19_tests)
