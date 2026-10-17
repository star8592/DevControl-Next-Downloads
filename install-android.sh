#!/usr/bin/env bash
# Install DevControl Next APK on a USB-connected Android device via ADB.
set -Eeuo pipefail
tag=v0.1.0-preview.1
name=devcontrol-next-agent-android.apk
base="https://github.com/star8592/DevControl-Next-Downloads/releases/download/$tag"
for bin in adb curl sha256sum; do command -v "$bin" >/dev/null || { echo "Missing $bin" >&2; exit 3; }; done
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
curl -fLsS --retry 2 "$base/$name" -o "$dir/$name"
curl -fLsS --retry 2 "$base/$name.sha256" -o "$dir/$name.sha256"
(cd "$dir" && sha256sum -c "$name.sha256")
count=$(adb devices | grep -c $'\tdevice$' || true)
[[ "$count" == 1 ]] || { echo "Connect exactly one authorized USB-debugging Android device (found $count)" >&2; exit 4; }
echo "Installing separate dev.devcontrol.next.agent application (QA preview signing)"
adb install -r "$dir/$name"
echo "NEXT_ANDROID_PREVIEW_INSTALLED. Device pairing awaits mcpx.devcontrol.dev deployment."
