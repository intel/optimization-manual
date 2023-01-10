set(amx_ex6_srcs ex6_test.cpp)
add_executable(amx_ex6_tests ${amx_ex6_srcs})
target_link_libraries(amx_ex6_tests gtest_main)
add_test(NAME amx_ex6_test COMMAND amx_ex6_tests)
