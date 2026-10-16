#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$repo_root/scripts/cloud-env.sh"
cd "$repo_root/apps/mobile"
flutter build apk --debug
mkdir -p /workspace/deliverables
cp build/app/outputs/flutter-apk/app-debug.apk /workspace/deliverables/saprima-kasir-0.1.0-debug.apk
cd /workspace/deliverables
sha256sum saprima-kasir-0.1.0-debug.apk > SHA256SUMS
"$ANDROID_HOME/build-tools/36.0.0/apksigner" verify --verbose saprima-kasir-0.1.0-debug.apk
