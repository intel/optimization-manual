if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
    check_cxx_compiler_flag("-mamx-int8 -mamx-tile" COMPILER_SUPPORTS_AMX)
    if (COMPILER_SUPPORTS_AMX)
        set_property(SOURCE ex17_test.cpp APPEND PROPERTY COMPILE_OPTIONS "-DCOMPILER_SUPPORTS_AMX")
        set(amx_exx_ass amx_post_conv_gemm_relu_ass.s)
    endif()
elseif(MSVC)
    set(amx_exx_ass amx_post_conv_gemm_relu_ass.asm)
    set_property(SOURCE ex17_test.cpp APPEND PROPERTY COMPILE_OPTIONS "/DCOMPILER_SUPPORTS_AMX")
endif()

set(amx_ex17_srcs ex17_test.cpp ${amx_exx_ass})
add_executable(amx_ex17_tests ${amx_ex17_srcs})
target_link_libraries(amx_ex17_tests gtest_main optimisation_common)
add_test(NAME amx_ex17_test COMMAND amx_ex17_tests)
