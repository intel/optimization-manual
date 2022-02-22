if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex27_ass s2s_vscatterdps.s s2s_vpermi2d.s)
elseif(MSVC)
set(avx512_ex27_ass s2s_vscatterdps.asm s2s_vpermi2d.asm)
endif()
add_executable(avx512_ex27_tests ex27_test.cpp s2s_vscatterdps.c s2s_verpmi2d.c ${avx512_ex27_ass})
target_link_libraries(avx512_ex27_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex27_bench ex27_bench.cpp ${avx512_ex27_ass})
  target_link_libraries(avx512_ex27_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex27_test COMMAND avx512_ex27_tests)
