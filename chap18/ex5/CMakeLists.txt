if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex5_ass mul_nomask_avx512.s mul_mask_avx512.s mul_zeromask_avx512.s)
elseif(MSVC)
set(avx512_ex5_ass mul_nomask_avx512.asm mul_mask_avx512.asm mul_zeromask_avx512.asm)
endif()

add_executable(avx512_ex5_tests ex5_test.cpp mul_nomask_avx512.c mul_mask_avx512.c mul_zeromask_avx512.c ${avx512_ex5_ass})
target_link_libraries(avx512_ex5_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex5_bench ex5_bench.cpp ${avx512_ex5_ass})
  target_link_libraries(avx512_ex5_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex5_test COMMAND avx512_ex5_tests)
