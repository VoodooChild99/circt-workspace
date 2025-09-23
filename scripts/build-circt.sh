#!/bin/bash

build_llvm_debug() {
    cd /home/user/circt/llvm || exit 1
    if [ -d build/Debug ]; then
        rm -rf build/Debug
    fi
    mkdir -p build/Debug
    cd build/Debug || exit 1
    cmake -G Ninja ../../llvm \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
        -DLLVM_ENABLE_PROJECTS="mlir" \
        -DLLVM_TARGETS_TO_BUILD="host" \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DCMAKE_BUILD_TYPE=Debug \
        -DLLVM_USE_SPLIT_DWARF=ON \
        -DLLVM_ENABLE_LLD=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    echo "[+] building LLVM Debug"
    ninja -j"$(nproc)"
}

build_llvm_release() {
    cd /home/user/circt/llvm || exit 1
    if [ -d build/Release ]; then
        rm -rf build/Release
    fi
    mkdir -p build/Release
    cd build/Release || exit 1
    cmake -G Ninja ../../llvm \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
        -DLLVM_ENABLE_PROJECTS="mlir" \
        -DLLVM_TARGETS_TO_BUILD="host" \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_USE_SPLIT_DWARF=ON \
        -DLLVM_ENABLE_LLD=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    echo "[+] building LLVM Release"
    ninja -j"$(nproc)"
}

build_circt_debug() {
    cd /home/user/circt || exit 1
    if [ -d build/Debug ]; then
        rm -rf build/Debug
    fi
    mkdir -p build/Debug
    cd build/Debug || exit 1
    cmake -G Ninja ../.. \
        -DMLIR_DIR="$PWD"/../../llvm/build/Debug/lib/cmake/mlir \
        -DLLVM_DIR="$PWD"/../../llvm/build/Debug/lib/cmake/llvm \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DCMAKE_BUILD_TYPE=Debug \
        -DLLVM_USE_SPLIT_DWARF=ON \
        -DLLVM_ENABLE_LLD=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCIRCT_SLANG_FRONTEND_ENABLED=ON
    echo "[+] building CIRCT Debug"
    ninja -j"$(nproc)"
}

build_circt_release() {
    cd /home/user/circt || exit 1
    if [ -d build/Release ]; then
        rm -rf build/Release
    fi
    mkdir -p build/Release
    cd build/Release || exit 1
    cmake -G Ninja ../.. \
        -DMLIR_DIR="$PWD"/../../llvm/build/Release/lib/cmake/mlir \
        -DLLVM_DIR="$PWD"/../../llvm/build/Release/lib/cmake/llvm \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_USE_SPLIT_DWARF=ON \
        -DLLVM_ENABLE_LLD=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCIRCT_SLANG_FRONTEND_ENABLED=ON
    echo "[+] building CIRCT Release"
    ninja -j"$(nproc)"
}

print_usage() {
    echo "Usage: build-circt.sh <all/llvm/circt> <all/debug/release> "
    exit 1
}

if (( $# < 2 )); then
    print_usage
fi

TARGET="$1"
PROFILE="$2"

if [ "$TARGET" = "llvm" ]; then
    if [ "$PROFILE" = "debug" ]; then
        build_llvm_debug
    elif [ "$PROFILE" = "release" ]; then
        build_llvm_release
    elif [ "$PROFILE" = "all" ]; then
        build_llvm_debug
        build_llvm_release
    else
        print_usage
    fi
elif [ "$TARGET" = "circt" ]; then
    if [ "$PROFILE" = "debug" ]; then
        build_circt_debug
    elif [ "$PROFILE" = "release" ]; then
        build_circt_release
    elif [ "$PROFILE" = "all" ]; then
        build_circt_debug
        build_circt_release
    else
        print_usage
    fi
elif [ "$TARGET" = "all" ]; then
    if [ "$PROFILE" = "debug" ]; then
        build_llvm_debug
        build_circt_debug
    elif [ "$PROFILE" = "release" ]; then
        build_llvm_release
        build_circt_release
    elif [ "$PROFILE" = "all" ]; then
        build_llvm_debug
        build_circt_debug
        build_llvm_release
        build_circt_release
    else
        print_usage
    fi
else
    print_usage
fi
