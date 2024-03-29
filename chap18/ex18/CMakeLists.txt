if(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES AppleClang)
set(avx512_ex18_ass qword_avx2_ass.s qword_avx512_ass.s)
set_property(SOURCE qword_avx512_intrinsics.c APPEND PROPERTY COMPILE_OPTIONS "-mavx512f" "-mavx512dq")
elseif(MSVC)
set(avx512_ex18_ass qword_avx2_ass.asm qword_avx512_ass.asm)
endif()
add_executable(avx512_ex18_tests ex18_test.cpp qword_avx2_intrinsics.c qword_avx2.c qword_avx512_intrinsics.c qword_avx512.c ${avx512_ex18_ass})
target_link_libraries(avx512_ex18_tests gtest_main optimisation_common)

IF( benchmark_FOUND )
  add_executable(avx512_ex18_bench ex18_bench.cpp qword_avx2_intrinsics.c qword_avx512_intrinsics.c ${avx512_ex18_ass})
  target_link_libraries(avx512_ex18_bench benchmark::benchmark optimisation_common)
ENDIF()

add_test(NAME avx512_ex18_test COMMAND avx512_ex18_tests)
