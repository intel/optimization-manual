if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex14_ass register_broadcast.s memory_broadcast.s embedded_broadcast.s)
elseif(MSVC)
set(avx512_ex14_ass register_broadcast.asm memory_broadcast.asm embedded_broadcast.asm)
endif()
add_executable(avx512_ex14_tests ex14_test.cpp register_broadcast.c memory_broadcast.c embedded_broadcast.c ${avx512_ex14_ass})
target_link_libraries(avx512_ex14_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex14_bench ex14_bench.cpp ${avx512_ex14_ass})
  target_link_libraries(avx512_ex14_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex14_test COMMAND avx512_ex14_tests)
