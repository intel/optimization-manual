if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex3_ass poly_sse.s poly_avx_128.s poly_avx_256.s)
elseif(MSVC)
set(avx_ex3_ass poly_sse.asm poly_avx_128.asm poly_avx_256.asm)
endif()

add_executable(avx_ex3_tests ex3_test.cpp poly_sse.c poly_avx_128.c poly_avx_256.c ${avx_ex3_ass})
target_link_libraries(avx_ex3_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex3_bench ex3_bench.cpp ${avx_ex3_ass})
  target_link_libraries(avx_ex3_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex3_test COMMAND avx_ex3_tests)
