if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(sse_ex3_ass swizzling_sse.s)
elseif(MSVC)
set(sse_ex3_ass swizzling_sse.asm)
endif()

add_executable(sse_ex3_tests ex3_test.cpp swizzling_sse.c ${sse_ex3_ass})
target_link_libraries(sse_ex3_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(sse_ex3_bench ex3_bench.cpp ${sse_ex3_ass})
  target_link_libraries(sse_ex3_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME sse_ex3_test COMMAND sse_ex3_tests)
