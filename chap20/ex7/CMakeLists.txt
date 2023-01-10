set(amx_ex7_srcs ex7_test.cpp)
add_executable(amx_ex7_tests ${amx_ex7_srcs})
target_link_libraries(amx_ex7_tests gtest_main)
add_test(NAME amx_ex7_test COMMAND amx_ex7_tests)
