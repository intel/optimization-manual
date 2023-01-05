set(amx_ex14_srcs ex14_test.cpp)
add_executable(amx_ex14_tests ${amx_ex14_srcs})
target_link_libraries(amx_ex14_tests gtest_main)
add_test(NAME amx_ex14_test COMMAND amx_ex14_tests)
