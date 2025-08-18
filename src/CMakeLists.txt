# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(xxhash_library VERSION 0.0.1 LANGUAGES C)

add_library(xxhash SHARED
  "xxhash.c"
)

set_target_properties(xxhash PROPERTIES
  PUBLIC_HEADER xxhash.h
  OUTPUT_NAME "xxhash"
)

target_compile_definitions(xxhash PUBLIC DART_SHARED_LIB)

if(ANDROID)
  target_link_options(xxhash PRIVATE "-Wl,-z,max-page-size=16384")
endif()
