set(fp16_ex3_srcs complex_from_real_mask_or.cpp)
if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE complex_from_real_mask_or.cpp APPEND PROPERTY COMPILE_OPTIONS "-mavx512f" "-mavx512bw" "-mavx512vl" "-mavx512dq")
endif()
add_executable(fp16_ex3_tests ex3_test.cpp ${fp16_ex3_srcs})
target_link_libraries(fp16_ex3_tests gtest_main optimisation_common)

add_test(NAME fp16_ex3_test COMMAND fp16_ex3_tests)
