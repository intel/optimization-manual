set(amx_ex16_srcs ex16_test.cpp)
add_executable(amx_ex16_tests ${amx_ex16_srcs})
target_link_libraries(amx_ex16_tests gtest_main)
add_test(NAME amx_ex16_test COMMAND amx_ex16_tests)
