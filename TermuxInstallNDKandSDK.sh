#!/bin/bash

# Function to check Java version
check_java_version() {
    if command -v java &>/dev/null; then
        java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | sed 's/^1\.//')
        echo "Java version detected: $java_version"
        if [[ "$java_version" -ge 11 ]]; then
            echo "Compatible Java version found."
        else
            echo "Java version is too old. Installing OpenJDK 11..."
            install_java
        fi
    else
        echo "Java not found. Installing OpenJDK 11..."
        install_java
    fi
}

# Function to install OpenJDK 11
install_java() {
    pkg install -y openjdk-11
    export JAVA_HOME=$(dirname $(dirname $(realpath $(which java))))
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
    echo "export PATH=\$PATH:$JAVA_HOME/bin" >> ~/.bashrc
    source ~/.bashrc
}

# Install necessary packages
pkg update && pkg upgrade -y
pkg install -y ndk-sysroot clang wget unzip

# Check and install Java if needed
check_java_version

# Install Precompiled NDK (optimized for aarch64)
mkdir -p ~/android-ndk
wget -P ~/android-ndk https://github.com/lzhiyong/termux-ndk/releases/download/android-ndk-r25c/android-ndk-r25c-aarch64.zip
unzip ~/android-ndk/android-ndk-r25c-aarch64.zip -d ~/android-ndk
rm ~/android-ndk/android-ndk-r25c-aarch64.zip

# Set up NDK environment variables
export ANDROID_NDK_HOME=~/android-ndk/android-ndk-r25c
export PATH=$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-aarch64/bin
echo "export ANDROID_NDK_HOME=$ANDROID_NDK_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-aarch64/bin" >> ~/.bashrc
source ~/.bashrc

# Test NDK setup
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-aarch64/bin/clang --version || echo "NDK setup failed!"

# Install SDK (optimized for Termux)
mkdir -p ~/android-sdk
wget -P ~/android-sdk https://github.com/lzhiyong/termux-sdk/releases/download/android-sdk/android-sdk-aarch64.zip
unzip ~/android-sdk/android-sdk-aarch64.zip -d ~/android-sdk
rm ~/android-sdk/android-sdk-aarch64.zip

# Set up SDK environment variables
export ANDROID_SDK_ROOT=~/android-sdk/cmdline-tools/latest
export PATH=$PATH:$ANDROID_SDK_ROOT/bin:$ANDROID_SDK_ROOT/platform-tools
echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> ~/.bashrc
echo "export PATH=\$PATH:$ANDROID_SDK_ROOT/bin:$ANDROID_SDK_ROOT/platform-tools" >> ~/.bashrc
source ~/.bashrc

# Install essential SDK tools and packages
sdkmanager --sdk_root=$ANDROID_SDK_ROOT --install "build-tools;34.0.0" "platforms;android-34" "platform-tools" || echo "SDK setup failed!"

# Test SDK setup
adb --version || echo "ADB setup failed!"

echo "NDK (r25c) and SDK tools are ready-to-go!"
