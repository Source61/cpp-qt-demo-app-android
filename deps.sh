#!/bin/bash
set -e

QT_VERSION="${QT_VERSION:-6.8.0}"
QT_ROOT="${QT_ROOT:-$HOME/Qt/$QT_VERSION}"
ANDROID_SDK="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"

echo "=== Installing system packages ==="
sudo apt-get update
sudo apt-get install -y \
  build-essential cmake ninja-build \
  python3 python3-pip pipx \
  default-jdk \
  libgl1-mesa-dev libxkbcommon-dev

echo ""
echo "=== Installing aqtinstall ==="
pipx install aqtinstall
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "=== Installing Qt $QT_VERSION (desktop + android) ==="
aqt install-qt linux desktop "$QT_VERSION" linux_gcc_64 -O "$HOME/Qt"
aqt install-qt linux android "$QT_VERSION" android_arm64_v8a -O "$HOME/Qt"

echo ""
echo "=== Installing Android SDK/NDK ==="
CMDLINE_TOOLS="$ANDROID_SDK/cmdline-tools/latest"
if [ ! -d "$CMDLINE_TOOLS" ]; then
  mkdir -p "$ANDROID_SDK/cmdline-tools"
  cd /tmp
  curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
  unzip -qo commandlinetools-linux-11076708_latest.zip
  mv cmdline-tools "$CMDLINE_TOOLS"
  rm commandlinetools-linux-11076708_latest.zip
  cd -
fi

yes | "$CMDLINE_TOOLS/bin/sdkmanager" --sdk_root="$ANDROID_SDK" \
  "platform-tools" \
  "platforms;android-34" \
  "ndk;27.1.12297006" \
  "build-tools;34.0.0"

echo ""
echo "=== Done ==="
echo ""
echo "Add to your shell profile:"
echo "  export QT_ROOT=$QT_ROOT"
echo "  export ANDROID_SDK_ROOT=$ANDROID_SDK"
echo "  export ANDROID_NDK_ROOT=$ANDROID_SDK/ndk/27.1.12297006"
echo "  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
