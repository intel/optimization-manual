if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(amx_ex22_ass flat_to_flat_bf16_trans.s)
elseif(MSVC)
set(amx_ex22_ass flat_to_flat_bf16_trans.asm)
endif()

add_executable(amx_ex22_tests ex22_test.cpp ${amx_ex22_ass})

target_link_libraries(amx_ex22_tests gtest_main optimisation_common)

add_test(NAME amx_ex22_tests COMMAND amx_ex22_tests)
