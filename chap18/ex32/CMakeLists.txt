if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex32_ass single_sqrt_24.s single_sqrt_23.s single_sqrt_14.s)
elseif(MSVC)
set(avx512_ex32_ass single_sqrt_24.asm single_sqrt_23.asm single_sqrt_14.asm)
endif()
add_executable(avx512_ex32_tests ex32_test.cpp single_sqrt_24.c single_sqrt_23.c single_sqrt_14.c ${avx512_ex32_ass})

target_link_libraries(avx512_ex32_tests gtest_main optimisation_common)
add_test(NAME avx512_ex32_test COMMAND avx512_ex32_tests)
