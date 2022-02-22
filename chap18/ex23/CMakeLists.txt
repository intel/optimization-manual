if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex23_ass decompress_novbmi.s decompress_vbmi.s)
elseif(MSVC)
set(avx512_ex23_ass decompress_novbmi.asm decompress_vbmi.asm)
endif()
add_executable(avx512_ex23_tests ex23_test.cpp decompress_novbmi.c decompress_vbmi.c ${avx512_ex23_ass})
target_link_libraries(avx512_ex23_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex23_bench ex23_bench.cpp ${avx512_ex23_ass})
  target_link_libraries(avx512_ex23_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex23_test COMMAND avx512_ex23_tests)
