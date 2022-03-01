if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex12_ass saxpy32.s saxpy16.s)
elseif(MSVC)
set(avx_ex12_ass saxpy32.asm saxpy16.asm)
endif()
add_executable(avx_ex12_tests ex12_test.cpp saxpy32.c saxpy16.c ${avx_ex12_ass})
target_link_libraries(avx_ex12_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex12_bench ex12_bench.cpp ${avx_ex12_ass})
  target_link_libraries(avx_ex12_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex12_test COMMAND avx_ex12_tests)
