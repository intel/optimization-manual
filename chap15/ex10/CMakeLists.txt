if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex10_ass saxpy32.s)
elseif(MSVC)
set(avx_ex10_ass saxpy32.asm)
endif()
add_executable(avx_ex10_tests ex10_test.cpp saxpy32.c ${avx_ex10_ass})
target_link_libraries(avx_ex10_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex10_bench ex10_bench.cpp ${avx_ex10_ass})
  target_link_libraries(avx_ex10_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex10_test COMMAND avx_ex10_tests)
