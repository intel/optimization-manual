if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex33_ass double_div_53.s double_div_52.s double_div_26.s double_div_14.s)
elseif(MSVC)
set(avx512_ex33_ass double_div_53.asm double_div_52.asm double_div_26.asm double_div_14.asm)
endif()
add_executable(avx512_ex33_tests ex33_test.cpp double_div_53.c double_div_52.c double_div_26.c double_div_14.c ${avx512_ex33_ass})

target_link_libraries(avx512_ex33_tests gtest_main optimisation_common)
add_test(NAME avx512_ex33_test COMMAND avx512_ex33_tests)
