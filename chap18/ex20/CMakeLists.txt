if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex20_ass scalar_vector_dp.s avx512_vector_dp.s)
elseif(MSVC)
set(avx512_ex20_ass scalar_vector_dp.asm avx512_vector_dp.asm)
endif()
add_executable(avx512_ex20_tests ex20_test.cpp init_sparse.cpp scalar_vector_dp.c avx512_vector_dp.c ${avx512_ex20_ass})
target_link_libraries(avx512_ex20_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex20_bench ex20_bench.cpp init_sparse.cpp ${avx512_ex20_ass})
  target_link_libraries(avx512_ex20_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex20_test COMMAND avx512_ex20_tests)
