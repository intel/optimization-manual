set(amx_ex4_srcs ex4_test.cpp)
add_executable(amx_ex4_tests ${amx_ex4_srcs})
target_link_libraries(amx_ex4_tests gtest_main)
add_test(NAME amx_ex4_test COMMAND amx_ex4_tests)
