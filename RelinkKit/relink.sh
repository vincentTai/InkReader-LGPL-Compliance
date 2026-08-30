#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
mkdir -p "$ROOT/Output"
OBJECTS=()
while IFS= read -r object; do OBJECTS+=("$ROOT/$object"); done < "$ROOT/LinkInputs/InkReaderObjectFiles.txt"
xcrun --sdk iphoneos swiftc -target arm64-apple-ios17.0 \
  -sdk "$SDK" -emit-executable -o "$ROOT/Output/InkReader.relinked" \
  "${OBJECTS[@]}" \
  "$ROOT/Frameworks/MobiKit.xcframework/ios-arm64/MobiKit.framework/MobiKit" \
  -Xlinker -rpath -Xlinker @executable_path/Frameworks \
  -framework Foundation -framework UIKit -framework SwiftUI -framework PDFKit \
  -larchive
