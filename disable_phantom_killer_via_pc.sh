#!/bin/bash

# Check for ADB installation
if ! command -v adb &> /dev/null; then
    echo "ADB is not installed. Please install it and try again."
    exit 1
fi

# Ensure the device is connected
echo "Checking for connected devices..."
adb devices | grep -w "device" &> /dev/null
if [ $? -ne 0 ]; then
    echo "No device connected. Please connect your device and enable USB debugging."
    exit 1
fi

# Function to disable Phantom Process Killer for Termux
disable_phantom_killer() {
    echo "Disabling Phantom Process Killer for Termux..."
    
    # Grant Termux permission to run in the background
    adb shell dumpsys package com.termux | grep "userId=" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Termux is not installed or cannot be found on the device."
        exit 1
    fi
    
    # Disable Phantom Process Killer for Termux's UID
    TERMUX_UID=$(adb shell dumpsys package com.termux | grep userId= | awk -F= '{print $2}' | tr -d '\r')
    adb shell cmd device_config put activity_manager max_phantom_processes 2147483647
    adb shell cmd appops set com.termux RUN_IN_BACKGROUND allow
    adb shell cmd appops set com.termux START_FOREGROUND allow
    
    echo "Phantom Process Killer disabled for Termux (UID: $TERMUX_UID)."
}

# Function to automate ADB permissions setup for Termux
grant_permissions() {
    echo "Granting necessary permissions to Termux..."
    
    adb shell pm grant com.termux android.permission.READ_EXTERNAL_STORAGE
    adb shell pm grant com.termux android.permission.WRITE_EXTERNAL_STORAGE
    adb shell pm grant com.termux android.permission.FOREGROUND_SERVICE
    
    echo "Permissions granted."
}

# Main script logic
echo "Starting automation process..."
disable_phantom_killer
grant_permissions

echo "Process complete! Phantom Process Killer has been disabled, and permissions have been granted."
