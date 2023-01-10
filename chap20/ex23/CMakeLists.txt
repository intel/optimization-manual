if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(amx_ex23_ass vnni_to_vnni_bf16_trans.s)
elseif(MSVC)
set(amx_ex23_ass vnni_to_vnni_bf16_trans.asm)
endif()

add_executable(amx_ex23_tests ex23_test.cpp ${amx_ex23_ass})

target_link_libraries(amx_ex23_tests gtest_main optimisation_common)

add_test(NAME amx_ex23_tests COMMAND amx_ex23_tests)
