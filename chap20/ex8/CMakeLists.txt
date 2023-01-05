set(amx_ex8_srcs ex8_test.cpp)
add_executable(amx_ex8_tests ${amx_ex8_srcs})
target_link_libraries(amx_ex8_tests gtest_main)
add_test(NAME amx_ex8_test COMMAND amx_ex8_tests)
