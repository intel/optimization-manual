if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex48_ass mmx_min_max.s avx2_min_max.s)
elseif(MSVC)
set(avx_ex48_ass mmx_min_max.asm avx2_min_max.asm)
endif()
add_executable(avx_ex48_tests ex48_test.cpp mmx_min_max.c avx2_min_max.c ${avx_ex48_ass})
target_link_libraries(avx_ex48_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex48_bench ex48_bench.cpp ${avx_ex48_ass})
  target_link_libraries(avx_ex48_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex48_test COMMAND avx_ex48_tests)
