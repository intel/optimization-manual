add_executable(vnni_ex9_tests ex9_test.cpp pixel_shuffler.cpp)
target_link_libraries(vnni_ex9_tests gtest_main)
add_test(NAME vnni_ex9_test COMMAND vnni_ex9_tests)
