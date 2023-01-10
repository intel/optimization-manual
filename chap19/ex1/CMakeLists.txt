set(fp16_ex1_srcs real_from_complex_mask.cpp)
if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE real_from_complex_mask.cpp APPEND PROPERTY COMPILE_OPTIONS "-mavx512f" "-mavx512dq" "-mavx512bw" "-mavx512vl")
endif()
add_executable(fp16_ex1_tests ex1_test.cpp ${fp16_ex1_srcs})
target_link_libraries(fp16_ex1_tests gtest_main optimisation_common)

add_test(NAME fp16_ex1_test COMMAND fp16_ex1_tests)
