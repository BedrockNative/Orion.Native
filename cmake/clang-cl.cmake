# Same Windows x64 ABI on both hosts; only SDK discovery differs.
if(CMAKE_HOST_WIN32)
    # Use the SDK/CRT from an x64 Visual Studio developer environment.
    find_program(CMAKE_CXX_COMPILER NAMES clang-cl REQUIRED)
    find_program(CMAKE_LINKER NAMES lld-link REQUIRED)
    set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-windows-msvc)
    set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
else()
    include("${CMAKE_CURRENT_LIST_DIR}/clang-cl-x64.cmake")
endif()
