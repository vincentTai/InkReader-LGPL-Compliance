# Source manifest

| Component | Revision / version | License |
|---|---:|---|
| libmobi | `85dcfe803fc2a21020ddcf15c3eb66b93d388add` (v0.12) | LGPL-3.0-or-later |
| InkReader MobiKit wrapper and build scripts | Matching application release | LGPL-3.0-or-later when distributed as modifications to the linked library |

The build policy uses `USE_ENCRYPTION=OFF`, `USE_XMLWRITER=ON`,
`USE_LIBXML2=OFF`, `USE_ZLIB=OFF`, and `BUILD_SHARED_LIBS=ON`. The final
framework verifier rejects static Mach-O outputs and DRM/decryption symbols.
