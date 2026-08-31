# Relinking InkReader with a modified MobiKit

The supplied object files let a recipient relink the non-LGPL portion of the
matching InkReader release against a modified, ABI-compatible MobiKit. The
result is for verification and personal relinking; iOS platform signing and
installation rules still apply.

1. Install Xcode and select its command-line tools.
2. Modify `Source/libmobi` or `Source/MobiKit` as desired. Keep the public
   high-level API in `MobiKit.h` ABI-compatible.
3. From `Source`, run the exact framework build:

   ```sh
   ./build-mobikit.sh
   ./verify-mobikit.sh Frameworks/MobiKit.xcframework
   ```

4. Replace `RelinkKit/Frameworks/MobiKit.xcframework` with the newly built
   `Source/Frameworks/MobiKit.xcframework`.
5. Run `RelinkKit/relink.sh`. It expands the recorded Release link command,
   substitutes the new dynamic framework binary, and produces
   `Output/InkReader.relinked`.
6. Confirm the separate load command:

   ```sh
   otool -L Output/InkReader.relinked | grep MobiKit.framework/MobiKit
   ```

The package includes the matching release object files, package link inputs,
and recorded linker response file, so the command does not depend on access to
InkReader source code. Use an ABI-compatible Xcode/Swift toolchain, as Swift
object compatibility is tied to the compiler version.

`relink.sh` names only a few frameworks explicitly. That is sufficient: the
Swift driver reads the `LC_LINKER_OPTION` records the compiler embedded in the
supplied object files and autolinks the rest, including AVFAudio, MediaPlayer,
NaturalLanguage, CryptoKit and SwiftData.

## Verified end to end

This procedure was executed against the published tree, not just described:

1. `Source/build-mobikit.sh` rebuilt `MobiKit.xcframework` from the published
   libmobi and MobiKit sources alone.
2. `Source/MobiKit/src/MobiKit.c` was then modified, rebuilt, and the resulting
   framework binary was confirmed to carry the modification.
3. `RelinkKit/relink.sh` produced `Output/InkReader.relinked`, a Mach-O 64-bit
   arm64 executable, against that modified framework.
4. `otool -L` shows `@rpath/MobiKit.framework/MobiKit` as a separate load
   command, and `nm -mu` shows `_mobi_kit_convert_to_epub` as *undefined* in the
   executable:

   ```
   (undefined) external _mobi_kit_convert_to_epub (from MobiKit)
   ```

   The symbol is therefore resolved at load time from the replaceable framework,
   which is what LGPL-3 §4(d)(0) requires.

## Licenses

libmobi is LGPL-3.0-or-later. LGPL-3 incorporates the terms and conditions of
GPL-3, so both texts are part of the license and both are included here, as
[LICENSE-LGPL-3.0.txt](LICENSE-LGPL-3.0.txt) and
[LICENSE-GPL-3.0.txt](LICENSE-GPL-3.0.txt). The same two texts are reproduced
in the app under Settings → Open Source Licenses.
