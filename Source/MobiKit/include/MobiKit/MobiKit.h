#ifndef INKREADER_MOBIKIT_H
#define INKREADER_MOBIKIT_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MOBIKIT_EXPORT __attribute__((visibility("default")))

typedef enum {
    MOBIKIT_SUCCESS = 0,
    MOBIKIT_INVALID_FILE = 1,
    MOBIKIT_DRM_PROTECTED = 2,
    MOBIKIT_UNSUPPORTED = 3,
    MOBIKIT_WRITE_FAILED = 4
} MobiKitResult;

/// Converts an unprotected MOBI-family publication to EPUB.
/// No libmobi types or ownership cross this API boundary.
MOBIKIT_EXPORT MobiKitResult mobi_kit_convert_to_epub(
    const char *input_path,
    const char *output_path,
    char *error_message,
    size_t error_capacity
);

MOBIKIT_EXPORT const char *mobi_kit_libmobi_revision(void);

#ifdef __cplusplus
}
#endif

#endif
