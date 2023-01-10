if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(amx_ex25_ass flat_to_vnni_bf16_relayout.s)
elseif(MSVC)
set(amx_ex25_ass flat_to_vnni_bf16_relayout.asm)
endif()

add_executable(amx_ex25_tests ex25_test.cpp ${amx_ex25_ass})

target_link_libraries(amx_ex25_tests gtest_main optimisation_common)

add_test(NAME amx_ex25_tests COMMAND amx_ex25_tests)
