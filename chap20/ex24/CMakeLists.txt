if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(amx_ex24_ass flat_to_vnni_bf16_trans.s)
elseif(MSVC)
set(amx_ex24_ass flat_to_vnni_bf16_trans.asm)
endif()

add_executable(amx_ex24_tests ex24_test.cpp ${amx_ex24_ass})

target_link_libraries(amx_ex24_tests gtest_main optimisation_common)

add_test(NAME amx_ex24_tests COMMAND amx_ex24_tests)
