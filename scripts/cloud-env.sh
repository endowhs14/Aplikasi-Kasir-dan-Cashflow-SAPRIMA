#!/usr/bin/env bash
# Source this file. Toolchains live outside the application repository.
export PATH=/workspace/toolchains/flutter/bin:/workspace/toolchains/android-sdk/platform-tools:/workspace/toolchains/android-sdk/cmdline-tools/latest/bin:$PATH
export ANDROID_HOME=/workspace/toolchains/android-sdk
export ANDROID_SDK_ROOT=/workspace/toolchains/android-sdk
export ANDROID_USER_HOME=/workspace/toolchains/android-user
export ANDROID_EMULATOR_HOME=/workspace/toolchains/android-user
export ANDROID_AVD_HOME=/workspace/toolchains/avd
export XDG_RUNTIME_DIR=/workspace/toolchains/runtime
export GRADLE_USER_HOME=/workspace/toolchains/gradle
export PUB_CACHE=/workspace/toolchains/pub-cache
export XDG_CONFIG_HOME=/workspace/toolchains/config
export ANALYZER_STATE_LOCATION_OVERRIDE=/workspace/toolchains/analyzer
export FLUTTER_SUPPRESS_ANALYTICS=true
export CI=true
export JAVA_HOME=/workspace/toolchains/jdk-21.0.12.1+1
export PATH=$JAVA_HOME/bin:$PATH
