#!/bin/bash
set -e

TARGET="${1}"

if [ -z "$TARGET" ]; then
  echo "Usage: ./build.sh <android|ios|desktop>"
  exit 1
fi

# Qt root, e.g. ~/Qt/6.8.0
QT_ROOT="${QT_ROOT:-$HOME/Qt/6.8.0}"

case "$TARGET" in
  android)
    QT_ANDROID="${QT_ROOT}/android_arm64_v8a"
    QT_HOST="${QT_ROOT}/gcc_64"
    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
    NDK="${ANDROID_NDK_ROOT:-${ANDROID_SDK_ROOT}/ndk/$(ls "${ANDROID_SDK_ROOT}/ndk/" 2>/dev/null | sort -V | tail -1)}"
    BUILD_DIR="build-android"

    [ ! -d "$QT_ANDROID" ] && echo "Qt android kit not found at $QT_ANDROID" && exit 1
    [ ! -d "$QT_HOST" ] && echo "Qt host kit not found at $QT_HOST" && exit 1
    [ ! -d "$NDK" ] && echo "Android NDK not found. Set ANDROID_NDK_ROOT or ANDROID_SDK_ROOT" && exit 1

    cmake -B "$BUILD_DIR" \
      -DCMAKE_PREFIX_PATH="$QT_ANDROID" \
      -DCMAKE_FIND_ROOT_PATH="$QT_ANDROID" \
      -DQT_HOST_PATH="$QT_HOST" \
      -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
      -DCMAKE_BUILD_TYPE=Release \
      -DANDROID_ABI=arm64-v8a \
      -DANDROID_PLATFORM=android-26 \
      -DANDROID_SDK_ROOT:PATH="$ANDROID_SDK_ROOT"

    cmake --build "$BUILD_DIR" -j"$(nproc)"

    echo ""
    echo "Build done. To create APK:"
    echo "  $QT_HOST/bin/androiddeployqt --input $BUILD_DIR/android-mobileapp-deployment-settings.json --output $BUILD_DIR/android-build --android-platform android-34 --gradle"
    ;;

  ios)
    QT_IOS="${QT_ROOT}/ios"
    QT_HOST="${QT_ROOT}/macos"
    BUILD_DIR="build-ios"

    [ "$(uname)" != "Darwin" ] && echo "iOS builds require macOS" && exit 1
    [ ! -d "$QT_IOS" ] && echo "Qt iOS kit not found at $QT_IOS" && exit 1
    [ ! -d "$QT_HOST" ] && echo "Qt host kit not found at $QT_HOST" && exit 1

    cmake -B "$BUILD_DIR" -G Xcode \
      -DCMAKE_PREFIX_PATH="$QT_IOS" \
      -DQT_HOST_PATH="$QT_HOST" \
      -DCMAKE_SYSTEM_NAME=iOS \
      -DCMAKE_OSX_ARCHITECTURES=arm64

    cmake --build "$BUILD_DIR" --config Release -j"$(sysctl -n hw.ncpu)"

    echo ""
    echo "Build done. Open $BUILD_DIR/MobileApp.xcodeproj to deploy to device/simulator."
    ;;

  desktop)
    QT_DESKTOP="${QT_ROOT}/gcc_64"
    BUILD_DIR="build-desktop"

    [ ! -d "$QT_DESKTOP" ] && echo "Qt desktop kit not found at $QT_DESKTOP" && exit 1

    cmake -B "$BUILD_DIR" \
      -DCMAKE_PREFIX_PATH="$QT_DESKTOP" \
      -DCMAKE_BUILD_TYPE=Debug

    cmake --build "$BUILD_DIR" -j"$(nproc)"

    echo ""
    echo "Run: ./$BUILD_DIR/mobileapp"
    ;;

  *)
    echo "Unknown target: $TARGET"
    echo "Usage: ./build.sh <android|ios|desktop>"
    exit 1
    ;;
esac
