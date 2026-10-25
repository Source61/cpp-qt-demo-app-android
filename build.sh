#!/bin/bash
set -e

TARGET="${1}"

if [ -z "$TARGET" ]; then
  echo "Usage: ./build.sh <android|aab|ios|desktop>"
  exit 1
fi

# Qt root, e.g. ~/Qt/6.11.3
QT_ROOT="${QT_ROOT:-$HOME/Qt/6.11.3}"

case "$TARGET" in
  android|aab)
    QT_ANDROID="${QT_ROOT}/android_arm64_v8a"
    QT_HOST="${QT_ROOT}/gcc_64"
    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
    NDK="${ANDROID_NDK_ROOT:-${ANDROID_SDK_ROOT}/ndk/$(ls "${ANDROID_SDK_ROOT}/ndk/" 2>/dev/null | sort -V | tail -1)}"
    BUILD_DIR="build-android"

    [ ! -d "$QT_ANDROID" ] && echo "Qt android kit not found at $QT_ANDROID" && exit 1
    [ ! -d "$QT_HOST" ] && echo "Qt host kit not found at $QT_HOST" && exit 1
    [ ! -d "$NDK" ] && echo "Android NDK not found. Set ANDROID_NDK_ROOT or ANDROID_SDK_ROOT" && exit 1

    # Android only installs signed APKs. Unless QT_ANDROID_KEYSTORE_PATH, _ALIAS, _STORE_PASS and _KEY_PASS name a release key, sign with the SDK's debug key, made if missing.
    if [ -z "$QT_ANDROID_KEYSTORE_PATH" ]; then
      [ "$TARGET" = aab ] && echo "Google Play refuses the debug key: set QT_ANDROID_KEYSTORE_PATH, _ALIAS, _STORE_PASS and _KEY_PASS to your upload key" && exit 1
      export QT_ANDROID_KEYSTORE_PATH="$HOME/.android/debug.keystore" QT_ANDROID_KEYSTORE_ALIAS=androiddebugkey QT_ANDROID_KEYSTORE_STORE_PASS=android QT_ANDROID_KEYSTORE_KEY_PASS=android
      [ -f "$QT_ANDROID_KEYSTORE_PATH" ] || { mkdir -p "$HOME/.android" && keytool -genkeypair -keystore "$QT_ANDROID_KEYSTORE_PATH" -storepass android -keypass android -alias androiddebugkey -keyalg RSA -validity 10000 -dname "CN=Android Debug,O=Android,C=US"; }
    fi

    cmake -B "$BUILD_DIR" \
      -DQT_ANDROID_SIGN_APK=ON \
      -DQT_ANDROID_SIGN_AAB=ON \
      -DCMAKE_PREFIX_PATH="$QT_ANDROID" \
      -DCMAKE_FIND_ROOT_PATH="$QT_ANDROID" \
      -DQT_HOST_PATH="$QT_HOST" \
      -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
      -DCMAKE_BUILD_TYPE=Release \
      -DANDROID_ABI=arm64-v8a \
      -DANDROID_PLATFORM=android-28 \
      -DANDROID_SDK_ROOT:PATH="$ANDROID_SDK_ROOT"

    if [ "$TARGET" = aab ]; then
      cmake --build "$BUILD_DIR" -j"$(nproc)" --target aab
      echo ""
      echo "Build done. AAB for Google Play: $BUILD_DIR/android-build/build/outputs/bundle/release/android-build-release.aab"
    else
      cmake --build "$BUILD_DIR" -j"$(nproc)"
      echo ""
      echo "Build done. APK: $BUILD_DIR/android-build/build/outputs/apk/release/android-build-release-signed.apk"
      echo "Install: adb install -r <APK>, or copy it to the phone"
    fi
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
    echo "Usage: ./build.sh <android|aab|ios|desktop>"
    exit 1
    ;;
esac
