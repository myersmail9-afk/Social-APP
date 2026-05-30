#!/usr/bin/env bash
# Generates the Xcode project from project.yml and opens it.
# Requires a Mac with Xcode. Installs XcodeGen via Homebrew if missing.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XcodeGen not found. Installing via Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required. Install it from https://brew.sh and re-run." >&2
    exit 1
  fi
  brew install xcodegen
fi

echo "Generating Offline.xcodeproj..."
xcodegen generate

echo "Opening in Xcode..."
open Offline.xcodeproj

echo "Done. Press ▶︎ in Xcode to run on a simulator."
