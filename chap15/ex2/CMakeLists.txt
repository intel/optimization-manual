if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex2_ass transform_sse.s transform_avx.s)
elseif(MSVC)
set(avx_ex2_ass transform_sse.asm transform_avx.asm)
endif()

add_executable(avx_ex2_tests ex2_test.cpp transform_sse.c transform_avx.c ${avx_ex2_ass})
target_link_libraries(avx_ex2_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex2_bench ex2_bench.cpp ${avx_ex2_ass})
  target_link_libraries(avx_ex2_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex2_test COMMAND avx_ex2_tests)
