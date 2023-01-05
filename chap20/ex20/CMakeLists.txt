if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE int8_conv_test.cpp APPEND PROPERTY COMPILE_OPTIONS "-mavx512f")
set_property(SOURCE int8_conv_test.cpp APPEND PROPERTY COMPILE_OPTIONS "-mavx512bw")
endif()
set(amx_ex20_srcs ex20_test.cpp int8_conv_test.cpp)
add_executable(amx_ex20_tests ${amx_ex20_srcs})
target_link_libraries(amx_ex20_tests gtest_main optimisation_common)

add_test(NAME amx_ex20_test COMMAND amx_ex20_tests)
