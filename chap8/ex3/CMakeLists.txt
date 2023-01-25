set(vnni_ex3_srcs direct_conv.c)
if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE direct_conv.c APPEND PROPERTY COMPILE_OPTIONS "-Wall" "-mavx512f" "-mavx512vnni")
endif()
add_executable(vnni_ex3_tests ex3_test.cpp ${vnni_ex3_srcs})
target_link_libraries(vnni_ex3_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(vnni_ex3_bench ex3_bench.cpp ${vnni_ex3_srcs})
  target_link_libraries(vnni_ex3_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME vnni_ex3_test COMMAND vnni_ex3_tests)
