#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if test -d "$PROJECT_ROOT/Vendor/libmobi"; then
  LIBMOBI_ROOT="$PROJECT_ROOT/Vendor/libmobi"
  KIT_ROOT="$PROJECT_ROOT/Vendor/MobiKit"
  BUILD_ROOT="$PROJECT_ROOT/Build/MobiKit"
  OUTPUT="$PROJECT_ROOT/Frameworks/MobiKit.xcframework"
  VERIFY_SCRIPT="$PROJECT_ROOT/Scripts/verify-mobikit.sh"
else
  LIBMOBI_ROOT="$SCRIPT_DIR/libmobi"
  KIT_ROOT="$SCRIPT_DIR/MobiKit"
  BUILD_ROOT="$SCRIPT_DIR/Build/MobiKit"
  OUTPUT="$SCRIPT_DIR/Frameworks/MobiKit.xcframework"
  VERIFY_SCRIPT="$SCRIPT_DIR/verify-mobikit.sh"
fi
PINNED_REVISION="85dcfe803fc2a21020ddcf15c3eb66b93d388add"

if test -d "$LIBMOBI_ROOT/.git"; then
  test "$(git -C "$LIBMOBI_ROOT" rev-parse HEAD)" = "$PINNED_REVISION"
else
  test "$(tr -d '[:space:]' < "$SCRIPT_DIR/LIBMOBI_REVISION")" = "$PINNED_REVISION"
fi
rm -rf "$BUILD_ROOT" "$OUTPUT"
mkdir -p "$BUILD_ROOT" "$(dirname "$OUTPUT")"

# Record and validate the upstream policy configuration. Encryption must stay OFF.
cmake -S "$LIBMOBI_ROOT" -B "$BUILD_ROOT/policy" \
  -DUSE_ENCRYPTION=OFF \
  -DUSE_XMLWRITER=ON \
  -DUSE_LIBXML2=OFF \
  -DUSE_ZLIB=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release >/dev/null
grep -q '^USE_ENCRYPTION:BOOL=OFF$' "$BUILD_ROOT/policy/CMakeCache.txt"

SOURCES=(
  buffer.c compression.c debug.c index.c memory.c meta.c parse_rawml.c read.c
  structure.c util.c write.c opf.c xmlwriter.c miniz.c
)

build_slice() {
  local sdk="$1"
  local arch="$2"
  local platform_flag="$3"
  local slice="$BUILD_ROOT/$sdk-$arch"
  local sysroot
  sysroot="$(xcrun --sdk "$sdk" --show-sdk-path)"
  mkdir -p "$slice/objects"

  local common=(
    -arch "$arch" -isysroot "$sysroot" "$platform_flag" -std=c99 -O2 -fPIC
    -fvisibility=hidden -DPACKAGE_VERSION=\"0.12\" -DUSE_XMLWRITER -DUSE_MINIZ
    -D_POSIX_C_SOURCE=200112L
    -I"$LIBMOBI_ROOT/src" -I"$KIT_ROOT/include/MobiKit"
  )
  for source in "${SOURCES[@]}"; do
    xcrun --sdk "$sdk" clang "${common[@]}" -c "$LIBMOBI_ROOT/src/$source" \
      -o "$slice/objects/${source%.c}.o"
  done
  xcrun --sdk "$sdk" clang "${common[@]}" -c "$KIT_ROOT/src/MobiKit.c" \
    -o "$slice/objects/MobiKit.o"
  xcrun --sdk "$sdk" clang -arch "$arch" -isysroot "$sysroot" "$platform_flag" \
    -dynamiclib "$slice"/objects/*.o -o "$slice/MobiKit" \
    -install_name @rpath/MobiKit.framework/MobiKit \
    -Wl,-exported_symbols_list,"$KIT_ROOT/exported-symbols.txt" \
    -compatibility_version 1.0 -current_version 1.0
}

build_slice iphoneos arm64 -miphoneos-version-min=17.0
build_slice iphonesimulator arm64 -mios-simulator-version-min=17.0
build_slice iphonesimulator x86_64 -mios-simulator-version-min=17.0

make_framework() {
  local name="$1"
  local binary="$2"
  local platform="$3"
  local framework="$BUILD_ROOT/$name/MobiKit.framework"
  mkdir -p "$framework/Headers" "$framework/Modules"
  cp "$binary" "$framework/MobiKit"
  cp "$KIT_ROOT/include/MobiKit/MobiKit.h" "$framework/Headers/MobiKit.h"
  cp "$KIT_ROOT/module.modulemap" "$framework/Modules/module.modulemap"
  sed "s/__PLATFORM__/$platform/" "$KIT_ROOT/Info.plist.template" > "$framework/Info.plist"
}

make_framework device "$BUILD_ROOT/iphoneos-arm64/MobiKit" iPhoneOS
xcrun lipo -create \
  "$BUILD_ROOT/iphonesimulator-arm64/MobiKit" \
  "$BUILD_ROOT/iphonesimulator-x86_64/MobiKit" \
  -output "$BUILD_ROOT/MobiKit-simulator"
make_framework simulator "$BUILD_ROOT/MobiKit-simulator" iPhoneSimulator

xcodebuild -create-xcframework \
  -framework "$BUILD_ROOT/device/MobiKit.framework" \
  -framework "$BUILD_ROOT/simulator/MobiKit.framework" \
  -output "$OUTPUT"

"$VERIFY_SCRIPT" "$OUTPUT"
