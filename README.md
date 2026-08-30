# InkReader LGPL Compliance Source and Relink Kit

This directory is the publication-ready compliance payload for InkReader's
dynamic use of libmobi.

- libmobi version: 0.12
- exact revision: `85dcfe803fc2a21020ddcf15c3eb66b93d388add`
- license: LGPL-3.0-or-later
- linkage: dynamic `MobiKit.framework`
- encryption: disabled at build time

`Source/` is populated by `Scripts/prepare-relink-kit.sh` with the pinned
upstream tree, the MobiKit wrapper, and the exact framework build and
verification scripts. `RelinkKit/` contains the non-LGPL InkReader object files
from the matching Release build. See [RELINKING.md](RELINKING.md).

The `RelinkKit/Frameworks/MobiKit.xcframework` binary is independently
replaceable. Its only exported application-facing symbols are
`mobi_kit_convert_to_epub` and `mobi_kit_libmobi_revision`.

The public compliance repository is:
<https://github.com/vincentTai/InkReader-LGPL-Compliance>.
