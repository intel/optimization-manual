if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex20_ass ${avx_ex20_ass} vinsertps_transpose.s)
elseif(MSVC)
set(avx_ex20_ass ${avx_ex20_ass} vinsertps_transpose.asm)
endif()
add_executable(avx_ex20_tests ex20_test.cpp vinsertps_transpose.c ${avx_ex20_ass})
target_link_libraries(avx_ex20_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex20_bench ex20_bench.cpp ${avx_ex20_ass})
  target_link_libraries(avx_ex20_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex20_test COMMAND avx_ex20_tests)
