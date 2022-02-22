if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex10_ass scalar_compress.s avx_compress.s avx2_compress.s avx512_compress.s)
elseif(MSVC)
set(avx512_ex10_ass scalar_compress.asm avx_compress.asm avx2_compress.asm avx512_compress.asm)
endif()
add_executable(avx512_ex10_tests ex10_test.cpp scalar_compress.c avx_compress.c avx2_compress.c avx512_compress.c ${avx512_ex10_ass})
target_link_libraries(avx512_ex10_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex10_bench ex10_bench.cpp ${avx512_ex10_ass})
  target_link_libraries(avx512_ex10_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex10_test COMMAND avx512_ex10_tests)
