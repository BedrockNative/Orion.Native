set(CMAKE_TRY_COMPILE_CONFIGURATION Release)
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_VERSION 10.0)
set(CMAKE_SYSTEM_PROCESSOR AMD64)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/clang-cl-rules.cmake")

# Respect an explicit override; otherwise discover an existing xwin splat.
if(NOT XWIN_ROOT AND NOT "$ENV{XWIN_ROOT}" STREQUAL "")
    set(XWIN_ROOT "$ENV{XWIN_ROOT}" CACHE PATH "Windows SDK/MSVC root" FORCE)
endif()
if(NOT XWIN_ROOT)
    unset(XWIN_ROOT CACHE)
    set(_xwin_candidates "$ENV{HOME}/.local/share/xwin" "$ENV{HOME}/.xwin" "$ENV{HOME}/xwin")
    if(NOT "$ENV{XDG_DATA_HOME}" STREQUAL "")
        list(PREPEND _xwin_candidates "$ENV{XDG_DATA_HOME}/xwin")
    endif()
    find_path(XWIN_ROOT NAMES sdk/include/um/windows.h
        PATHS ${_xwin_candidates} NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH
        DOC "Discovered Windows SDK/MSVC root prepared by xwin splat")
endif()
if(NOT XWIN_ROOT)
    message(FATAL_ERROR "xwin SDK not found. Set the environment variable XWIN_ROOT to your xwin splat directory (containing sdk/ and crt/), then configure again: export XWIN_ROOT=/path/to/xwin")
endif()
get_filename_component(XWIN_ROOT "${XWIN_ROOT}" ABSOLUTE)
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES XWIN_ROOT)

if(NOT EXISTS "${XWIN_ROOT}/sdk/include/um/windows.h"
   OR NOT EXISTS "${XWIN_ROOT}/crt/include/vcruntime.h"
   OR NOT EXISTS "${XWIN_ROOT}/crt/include/vector")
    message(FATAL_ERROR "Windows SDK/MSVC headers not found at ${XWIN_ROOT}. Set the environment variable XWIN_ROOT to a complete xwin splat directory; see README.txt.")
endif()

find_program(CMAKE_C_COMPILER NAMES clang-cl REQUIRED)
set(CMAKE_CXX_COMPILER "${CMAKE_C_COMPILER}")
set(CMAKE_C_COMPILER_TARGET x86_64-pc-windows-msvc)
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-windows-msvc)
find_program(CMAKE_LINKER NAMES lld-link REQUIRED)

# lld-link also provides the LLVM librarian when invoked with /lib.
find_program(CMAKE_AR NAMES llvm-lib)
if(NOT CMAKE_AR)
    set(CMAKE_AR "${CMAKE_LINKER}")
endif()

set(_sdk_includes "")
foreach(directory IN ITEMS crt/include sdk/include/ucrt sdk/include/shared sdk/include/um sdk/include/winrt)
    string(APPEND _sdk_includes " /imsvc\"${XWIN_ROOT}/${directory}\"")
endforeach()
set(CMAKE_C_FLAGS_INIT "${_sdk_includes}")
set(CMAKE_CXX_FLAGS_INIT "${_sdk_includes}")

set(_sdk_libraries "")
foreach(directory IN ITEMS crt/lib/x86_64 sdk/lib/ucrt/x86_64 sdk/lib/um/x86_64)
    string(APPEND _sdk_libraries " /libpath:\"${XWIN_ROOT}/${directory}\"")
endforeach()
# Embed manifests directly with LLD; no Windows SDK executables are needed.
set(CMAKE_EXE_LINKER_FLAGS_INIT "${_sdk_libraries} /manifest:embed /incremental:no")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${_sdk_libraries} /manifest:embed /incremental:no")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${_sdk_libraries} /manifest:embed /incremental:no")

foreach(library IN ITEMS crt/lib/x86_64/libcmt.lib sdk/lib/ucrt/x86_64/libucrt.lib sdk/lib/um/x86_64/kernel32.lib)
    if(NOT EXISTS "${XWIN_ROOT}/${library}")
        message(FATAL_ERROR "Missing xwin library: ${XWIN_ROOT}/${library}. Splat both headers and libraries for x86_64.")
    endif()
endforeach()
