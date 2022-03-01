if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx_ex23_ass rcpps_sse.s vrcpps_avx.s)
elseif(MSVC)
set(avx_ex23_ass rcpps_sse.asm vrcpps_avx.asm)
endif()
add_executable(avx_ex23_tests ex23_test.cpp rcpps_sse.c vrcpps_avx.c ${avx_ex23_ass})
target_link_libraries(avx_ex23_tests gtest_main)

IF( benchmark_FOUND )
  add_executable(avx_ex23_bench ex23_bench.cpp ${avx_ex23_ass})
  target_link_libraries(avx_ex23_bench benchmark::benchmark)
ENDIF()

add_test(NAME avx_ex23_test COMMAND avx_ex23_tests)
