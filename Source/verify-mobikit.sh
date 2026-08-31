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

# A missing tool must fail the audit, never pass it silently.
for tool in file nm strings grep find; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required tool '$tool' is unavailable; cannot verify MobiKit" >&2
    exit 1
  fi
done

slices=0

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
  slices=$((slices + 1))
done < <(find "$XCFRAMEWORK" -path '*/MobiKit.framework/MobiKit' -type f)

if test "$slices" -eq 0; then
  echo "No MobiKit slices found in $XCFRAMEWORK; nothing was verified" >&2
  exit 1
fi

if test -d "$BUILD_ROOT"; then
  if grep -rEn '^#define USE_ENCRYPTION| -DUSE_ENCRYPTION' "$BUILD_ROOT"; then
    echo 'Encryption was enabled during the MobiKit build' >&2
    exit 1
  fi
  build_flags_audited=yes
else
  build_flags_audited=no
fi

echo "MobiKit: $slices slice(s) verified dynamic, with no DRM/decryption symbols."
if test "$build_flags_audited" = yes; then
  echo 'MobiKit: build tree audited; USE_ENCRYPTION was never defined.'
else
  echo "MobiKit: build tree $BUILD_ROOT absent, so build flags were not audited."
  echo 'MobiKit: the binary symbol and string checks above still hold.'
fi
