add_executable(avx_ex41_tests ex41_test.cpp i64toa_avx2.c)
target_link_libraries(avx_ex41_tests gtest_main)
target_include_directories(avx_ex41_tests
    PUBLIC
        ../ex40
        ../ex42
)
add_test(NAME avx_ex41_test COMMAND avx_ex41_tests)
      
IF( benchmark_FOUND )
  add_executable(avx_ex41_bench ex41_bench.cpp i64toa_avx2.c)
  target_link_libraries(avx_ex41_bench benchmark::benchmark)
  target_include_directories(avx_ex41_bench
    PUBLIC
        ../ex40
        ../ex42
)
ENDIF()

