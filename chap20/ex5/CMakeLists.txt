set(amx_ex5_srcs ex5_test.cpp)
add_executable(amx_ex5_tests ${amx_ex5_srcs})
target_link_libraries(amx_ex5_tests gtest_main)
add_test(NAME amx_ex5_test COMMAND amx_ex5_tests)
