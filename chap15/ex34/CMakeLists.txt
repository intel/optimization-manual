if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex34_ass singlep.s halfp.s)
elseif(MSVC)
set(avx_ex34_ass singlep.asm halfp.asm)
endif()
add_executable(avx_ex34_tests ex34_test.cpp singlep.c halfp.c ${avx_ex34_ass})
target_link_libraries(avx_ex34_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex34_bench ex34_bench.cpp ${avx_ex34_ass})
  target_link_libraries(avx_ex34_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex34_test COMMAND avx_ex34_tests)
