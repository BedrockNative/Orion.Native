cmake_minimum_required(VERSION 3.25)

# The DLL uses the static release CRT in both supported configurations.
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
if(CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "Release;RelWithDebInfo" CACHE STRING "Build configurations" FORCE)
elseif(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build configuration" FORCE)
endif()
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Release RelWithDebInfo)

project(OrionNative VERSION 0.1.0 LANGUAGES CXX)

if(CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "Release;RelWithDebInfo" CACHE STRING "Build configurations" FORCE)
endif()

if(NOT WIN32 OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "Orion.Native requires a Windows x64 target. On Linux use the clang-cl-x64 toolchain.")
endif()
if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR NOT CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    message(FATAL_ERROR "Build with clang-cl (MSVC-compatible Clang).")
endif()
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE MATCHES "^(Release|RelWithDebInfo)$")
    message(FATAL_ERROR "Supported configurations: Release and RelWithDebInfo.")
endif()

add_library(OrionNativeHeaders INTERFACE)
add_library(orion::NativeHeaders ALIAS OrionNativeHeaders)
target_compile_features(OrionNativeHeaders INTERFACE cxx_std_20)
target_include_directories(OrionNativeHeaders INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")

add_library(OrionNative SHARED src/Main.cpp)
add_library(orion::Native ALIAS OrionNative)
target_link_libraries(OrionNative PUBLIC orion::NativeHeaders)
target_compile_definitions(OrionNative PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX)
target_compile_options(OrionNative PRIVATE /W4 /permissive- /utf-8)
target_link_options(OrionNative PRIVATE /INCREMENTAL:NO /OPT:REF /OPT:ICF)
set_target_properties(OrionNative PROPERTIES
    OUTPUT_NAME "Orion.Native"
    PREFIX ""
    CXX_EXTENSIONS OFF
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib"
    PDB_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin"
    COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/obj")
