if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex28_ass adj_vpgatherpd.s adj_load_masked_broadcast.s)
elseif(MSVC)
set(avx512_ex28_ass adj_vpgatherpd.asm adj_load_masked_broadcast.asm)
endif()
add_executable(avx512_ex28_tests ex28_test.cpp adj_vpgatherpd.c adj_load_masked_broadcast.c ${avx512_ex28_ass})
target_link_libraries(avx512_ex28_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex28_bench ex28_bench.cpp ${avx512_ex28_ass})
  target_link_libraries(avx512_ex28_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex28_test COMMAND avx512_ex28_tests)
