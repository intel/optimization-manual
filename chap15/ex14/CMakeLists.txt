if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex14_ass cond_scalar.s cond_vmaskmov.s)
elseif(MSVC)
set(avx_ex14_ass cond_scalar.asm cond_vmaskmov.asm)
endif()
add_executable(avx_ex14_tests ex14_test.cpp cond_scalar.c cond_vmaskmov.c ${avx_ex14_ass})
target_link_libraries(avx_ex14_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex14_bench ex14_bench.cpp ${avx_ex14_ass})
  target_link_libraries(avx_ex14_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex14_test COMMAND avx_ex14_tests)
