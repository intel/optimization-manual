if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(sse_ex4_ass swizzling_unpck_sse.s)
elseif(MSVC)
set(sse_ex4_ass swizzling_unpck_sse.asm)
endif()

add_executable(sse_ex4_tests ex4_test.cpp swizzling_unpck_sse.c ${sse_ex4_ass})
target_link_libraries(sse_ex4_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(sse_ex4_bench ex4_bench.cpp ${sse_ex4_ass})
  target_link_libraries(sse_ex4_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME sse_ex4_test COMMAND sse_ex4_tests)
