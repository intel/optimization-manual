add_executable(avx_ex39_tests ex39_test.cpp klt_256.c)
target_link_libraries(avx_ex39_tests gtest_main)
target_include_directories(avx_ex39_tests
    PUBLIC
        ../ex38
)
add_test(NAME avx_ex39_test COMMAND avx_ex39_tests)
