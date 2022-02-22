if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex16_ass embedded_rounding.s manual_rounding.s)
elseif(MSVC)
set(avx512_ex16_ass embedded_rounding.asm manual_rounding.asm)
endif()
add_executable(avx512_ex16_tests ex16_test.cpp embedded_rounding.c manual_rounding.c ${avx512_ex16_ass})

target_link_libraries(avx512_ex16_tests gtest_main optimisation_common)
add_test(NAME avx512_ex16_test COMMAND avx512_ex16_tests)
