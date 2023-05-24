if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(sse_ex6_ass deswizzling_rgb_sse.s)
elseif(MSVC)
set(sse_ex6_ass deswizzling_rgb_sse.asm)
endif()

add_executable(sse_ex6_tests ex6_test.cpp deswizzling_rgb_sse.c ${sse_ex6_ass})
target_link_libraries(sse_ex6_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(sse_ex6_bench ex6_bench.cpp ${sse_ex6_ass})
  target_link_libraries(sse_ex6_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME sse_ex6_test COMMAND sse_ex6_tests)
