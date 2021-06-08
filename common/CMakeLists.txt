set(common_srcs optimisation_common.c)

if(CMAKE_CXX_COMPILER_ID MATCHES "^AppleClang$")
set(common_srcs ${common_srcs} ../chap5/ex15/supports_avx2.s supports_avx512_macos.s)
elseif(CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU)
set(common_srcs ${common_srcs} ../chap5/ex15/supports_avx2.s supports_avx512.s)
elseif(MSVC)
set(common_srcs ${common_srcs} ../chap5/ex15/supports_avx2.asm supports_avx512.asm)
endif()

ADD_LIBRARY(optimisation_common STATIC ${common_srcs})
