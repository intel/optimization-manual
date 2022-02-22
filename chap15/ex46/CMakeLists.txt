if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex46_ass scalar.s avx2_vpgatherd.s avx_vinsrt.s)
elseif(MSVC)
set(avx_ex46_ass scalar.asm avx2_vpgatherd.asm avx_vinsrt.asm)
endif()
add_executable(avx_ex46_tests ex46_test.cpp scalar.c avx2_vpgatherd.c avx_vinsrt.c ${avx_ex46_ass})
target_link_libraries(avx_ex46_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex46_bench ex46_bench.cpp ${avx_ex46_ass})
  target_link_libraries(avx_ex46_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex46_test COMMAND avx_ex46_tests)
