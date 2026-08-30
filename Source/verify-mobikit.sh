#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if test -d "$PROJECT_ROOT/Vendor/libmobi"; then
  DEFAULT_XCFRAMEWORK="$PROJECT_ROOT/Frameworks/MobiKit.xcframework"
  BUILD_ROOT="$PROJECT_ROOT/Build/MobiKit"
else
  DEFAULT_XCFRAMEWORK="$SCRIPT_DIR/Frameworks/MobiKit.xcframework"
  BUILD_ROOT="$SCRIPT_DIR/Build/MobiKit"
fi
XCFRAMEWORK="${1:-$DEFAULT_XCFRAMEWORK}"
test -d "$XCFRAMEWORK"

while IFS= read -r binary; do
  file "$binary" | grep -q 'dynamically linked shared library'
  symbols="$(nm -g "$binary")"
  if grep -Eq 'mobi_(drm|decrypt)|mobi_drm_decrypt' <<< "$symbols"; then
    echo "Forbidden libmobi DRM symbol found in $binary" >&2
    exit 1
  fi
  grep -q '_mobi_kit_convert_to_epub' <<< "$symbols"
  binary_strings="$(strings "$binary")"
  if grep -q 'mobi_drm_decrypt' <<< "$binary_strings"; then
    echo "Forbidden libmobi decryption implementation found in $binary" >&2
    exit 1
  fi
done < <(find "$XCFRAMEWORK" -path '*/MobiKit.framework/MobiKit' -type f)

if rg -n '^#define USE_ENCRYPTION| -DUSE_ENCRYPTION' "$BUILD_ROOT"; then
  echo 'Encryption was enabled during the MobiKit build' >&2
  exit 1
fi

echo 'MobiKit is dynamic and contains no DRM/decryption symbols.'
