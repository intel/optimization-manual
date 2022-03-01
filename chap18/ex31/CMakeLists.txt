if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex31_ass single_rcps_22.s single_rcps_23.s single_rcps_14.s)
elseif(MSVC)
set(avx512_ex31_ass single_rcps_22.asm single_rcps_23.asm single_rcps_14.asm)
endif()
add_executable(avx512_ex31_tests ex31_test.cpp single_rcps_22.c single_rcps_23.c single_rcps_14.c ${avx512_ex31_ass})

target_link_libraries(avx512_ex31_tests gtest_main optimisation_common)
add_test(NAME avx512_ex31_test COMMAND avx512_ex31_tests)
