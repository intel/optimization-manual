if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE post_conv.cpp APPEND PROPERTY COMPILE_OPTIONS "-mavx512f")
endif()
add_executable(vnni_ex5_tests ex5_test.cpp post_conv.cpp)
target_link_libraries(vnni_ex5_tests gtest_main optimisation_common)
add_test(NAME vnni_ex5_test COMMAND vnni_ex5_tests)
