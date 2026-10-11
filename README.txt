Orion.Native
============
C++20 Windows x64 DLL, built with CMake 3.25+, Ninja and clang-cl.
The same presets work on Windows (x64 VS developer shell with LLVM installed)
and Linux (LLVM and xwin SDK/CRT/STL).

  cmake --preset release
  cmake --build --preset release --parallel

  cmake --preset relwithdebinfo
  cmake --build --preset relwithdebinfo --parallel

On Linux the toolchain discovers an existing xwin SDK. If discovery fails,
set XWIN_ROOT=/path/to/xwin (the directory containing sdk/ and crt/).
Outputs: build/<preset>/bin/Orion.Native.dll and a PDB for RelWithDebInfo.
Both configurations use /MT. Runtime-Importer is not a dependency.

Public headers
--------------
include/Macros.hpp: IMPORT and EXPORT aliases for __declspec.
include/orion/InitializationContext.hpp: shared context containing a private
unordered_map<string, any>. Supply a Values map to the constructor or call set.
get<T> returns a const reference, throwing for missing keys or wrong types.
tryGet<T> returns a const pointer or nullptr; getOr<T> returns a supplied
fallback for missing keys or wrong types. contains checks key presence.
References/pointers remain owned by the context; keep it alive while using them.
set is for building the context before passing it by const reference.

CMake targets: orion::Native (DLL) and orion::NativeHeaders (public headers).

Branches
--------
main is the default branch; devel is the development branch.
