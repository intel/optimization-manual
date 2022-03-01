if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex35_ass double_sqrt_52.s double_sqrt_53.s double_sqrt_26.s double_sqrt_14.s)
elseif(MSVC)
set(avx512_ex35_ass double_sqrt_52.asm double_sqrt_53.asm double_sqrt_26.asm double_sqrt_14.asm)
endif()
add_executable(avx512_ex35_tests ex35_test.cpp double_sqrt_52.c double_sqrt_53.c double_sqrt_26.c double_sqrt_14.c ${avx512_ex35_ass})

target_link_libraries(avx512_ex35_tests gtest_main optimisation_common)
add_test(NAME avx512_ex35_test COMMAND avx512_ex35_tests)
