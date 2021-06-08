add_executable(avx_ex1_tests ex1_test.cpp transform_sse.c transform_avx.c)
target_link_libraries(avx_ex1_tests gtest_main)
add_test(NAME avx_ex1_test COMMAND avx_ex1_tests)
