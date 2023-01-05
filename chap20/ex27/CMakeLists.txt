if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set_property(SOURCE byte_decompression.c APPEND PROPERTY COMPILE_OPTIONS "-mavx512f" "-mavx512vbmi" "-mavx512vbmi2")
set_property(SOURCE ex27_test.cpp APPEND PROPERTY COMPILE_OPTIONS "-mpopcnt")
endif()

set(amx_ex27_src byte_decompression.c)

add_executable(amx_ex27_tests ex27_test.cpp ${amx_ex27_src})

target_link_libraries(amx_ex27_tests gtest_main optimisation_common)

add_test(NAME amx_ex27_tests COMMAND amx_ex27_tests)
