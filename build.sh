#!/bin/bash
# build.sh — Build the LocalizeWiz SDK
# Usage: ./build.sh <ios-sim|ios|mac|tvos-sim|spm>

set -e

SCHEME="LocalizeWiz"
PROJECT="LocalizeWiz.xcodeproj"

usage() {
    echo "Usage: ./build.sh <platform>"
    echo ""
    echo "  ios-sim    iOS Simulator (iPhone 16)"
    echo "  ios        iOS device"
    echo "  mac        macOS"
    echo "  tvos       tvOS device"
    echo "  tvos-sim   tvOS Simulator"
    echo "  spm        Swift Package Manager (swift build)"
    exit 1
}

case "${1:-}" in
  ios-sim)
    xcodebuild -scheme "$SCHEME" -project "$PROJECT" \
      -destination 'generic/platform=iOS Simulator' build
    ;;
  ios)
    xcodebuild -scheme "$SCHEME" -project "$PROJECT" \
      -destination 'generic/platform=iOS' \
      CODE_SIGNING_ALLOWED=NO build
    ;;
  mac)
    xcodebuild -scheme "$SCHEME" -project "$PROJECT" \
      -destination 'platform=macOS' \
      CODE_SIGNING_ALLOWED=NO build
    ;;
  tvos)
    xcodebuild -scheme "$SCHEME" -project "$PROJECT" \
      -destination 'generic/platform=tvOS' \
      CODE_SIGNING_ALLOWED=NO build
    ;;
  tvos-sim)
    xcodebuild -scheme "$SCHEME" -project "$PROJECT" \
      -destination 'generic/platform=tvOS Simulator' \
      CODE_SIGNING_ALLOWED=NO build
    ;;
  spm)
    swift build
    ;;
  *)
    usage
    ;;
esac
