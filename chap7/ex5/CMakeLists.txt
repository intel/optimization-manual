if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(sse_ex5_ass deswizzling_sse.s)
elseif(MSVC)
set(sse_ex5_ass deswizzling_sse.asm)
endif()

add_executable(sse_ex5_tests ex5_test.cpp deswizzling_sse.c ${sse_ex5_ass})
target_link_libraries(sse_ex5_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(sse_ex5_bench ex5_bench.cpp ${sse_ex5_ass})
  target_link_libraries(sse_ex5_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME sse_ex5_test COMMAND sse_ex5_tests)
