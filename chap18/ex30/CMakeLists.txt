if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex30_ass single_div_24.s single_div_23.s single_div_14.s)
elseif(MSVC)
set(avx512_ex30_ass single_div_24.asm single_div_23.asm single_div_14.asm)
endif()
add_executable(avx512_ex30_tests ex30_test.cpp single_div_24.c single_div_23.c single_div_14.c ${avx512_ex30_ass})

target_link_libraries(avx512_ex30_tests gtest_main optimisation_common)
add_test(NAME avx512_ex30_test COMMAND avx512_ex30_tests)
