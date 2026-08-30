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
