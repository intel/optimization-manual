if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex47_ass avx2_gatherpd.s avx_vinsert.s)
elseif(MSVC)
set(avx_ex47_ass avx2_gatherpd.asm avx_vinsert.asm)
endif()
add_executable(avx_ex47_tests ex47_test.cpp avx2_gatherpd.c avx_vinsert.c ${avx_ex47_ass})
target_link_libraries(avx_ex47_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex47_bench ex47_bench.cpp ${avx_ex47_ass})
  target_link_libraries(avx_ex47_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex47_test COMMAND avx_ex47_tests)
