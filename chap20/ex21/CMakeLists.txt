if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE embedding.c APPEND PROPERTY COMPILE_OPTIONS "-mavx512f")
endif()
set(amx_ex21_srcs ex21_test.cpp embedding.c)
add_executable(amx_ex21_tests ${amx_ex21_srcs})
target_link_libraries(amx_ex21_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(amx_ex21_bench ex21_bench.cpp embedding.c)
  target_link_libraries(amx_ex21_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME amx_ex21_test COMMAND amx_ex21_tests)
