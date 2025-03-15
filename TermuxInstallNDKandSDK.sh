#!/bin/bash

# Install necessary packages
pkg install -y ndk-sysroot clang wget openjdk-17

# Install Precompiled NDK
mkdir -p ~/android-ndk
wget -P ~/android-ndk https://dl.google.com/android/repository/android-ndk-r25c-linux.zip
unzip ~/android-ndk/android-ndk-r25c-linux.zip -d ~/android-ndk
rm ~/android-ndk/android-ndk-r25c-linux.zip

# Set up NDK environment variables
export ANDROID_NDK_HOME=~/android-ndk/android-ndk-r25c
export PATH=$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin
echo "export ANDROID_NDK_HOME=$ANDROID_NDK_HOME" >> ~/.bashrc
echo "export PATH=\$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin" >> ~/.bashrc
source ~/.bashrc

# Test NDK setup
clang --version

# Install SDK
mkdir -p ~/android-sdk
wget -P ~/android-sdk https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip ~/android-sdk/commandlinetools-linux-11076708_latest.zip -d ~/android-sdk
rm ~/android-sdk/commandlinetools-linux-11076708_latest.zip

# Set up SDK environment variables
export ANDROID_SDK_ROOT=~/android-sdk/cmdline-tools/latest
echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> ~/.bashrc
echo "export PATH=\$PATH:$ANDROID_SDK_ROOT/bin" >> ~/.bashrc
source ~/.bashrc

# Install SDK tools
sdkmanager --install "build-tools;34.0.0" "platforms;android-34" "platform-tools"

# Test SDK setup
adb --version

echo "Precompiled NDK (r25c) and SDK tools are ready-to-go."
