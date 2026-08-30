#include "MobiKit.h"

#include <mobi.h>
#define MINIZ_HEADER_FILE_ONLY
#define MINIZ_NO_ZLIB_COMPATIBLE_NAMES
#include <miniz.c>
#include <stdio.h>
#include <string.h>

#define EPUB_MIMETYPE "application/epub+zip"
#define EPUB_CONTAINER "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">\n\
  <rootfiles><rootfile full-path=\"OEBPS/content.opf\" media-type=\"application/oebps-package+xml\"/></rootfiles>\n\
</container>"

static void set_error(char *message, size_t capacity, const char *value) {
    if (message == NULL || capacity == 0) {
        return;
    }
    snprintf(message, capacity, "%s", value == NULL ? "Unknown conversion error" : value);
}

static int add_parts(mz_zip_archive *zip, const MOBIPart *part, const char *prefix, int resources) {
    char name[512];
    while (part != NULL) {
        MOBIFileMeta meta = mobi_get_filemeta_by_type(part->type);
        if (part->size > 0) {
            if (resources && meta.type == T_OPF) {
                snprintf(name, sizeof(name), "OEBPS/content.opf");
            } else {
                snprintf(name, sizeof(name), "OEBPS/%s%05zu.%s", prefix, part->uid, meta.extension);
            }
            if (!mz_zip_writer_add_mem(zip, name, part->data, part->size, MZ_DEFAULT_COMPRESSION)) {
                return 0;
            }
        }
        part = part->next;
    }
    return 1;
}

static int create_epub(const MOBIRawml *rawml, const char *output_path) {
    mz_zip_archive zip;
    memset(&zip, 0, sizeof(zip));
    if (!mz_zip_writer_init_file(&zip, output_path, 0)) {
        return 0;
    }
    if (!mz_zip_writer_add_mem(&zip, "mimetype", EPUB_MIMETYPE, sizeof(EPUB_MIMETYPE) - 1, MZ_NO_COMPRESSION) ||
        !mz_zip_writer_add_mem(&zip, "META-INF/container.xml", EPUB_CONTAINER, sizeof(EPUB_CONTAINER) - 1, MZ_DEFAULT_COMPRESSION) ||
        !add_parts(&zip, rawml->markup, "part", 0)) {
        mz_zip_writer_end(&zip);
        return 0;
    }
    if (rawml->flow != NULL && !add_parts(&zip, rawml->flow->next, "flow", 0)) {
        mz_zip_writer_end(&zip);
        return 0;
    }
    if (!add_parts(&zip, rawml->resources, "resource", 1) ||
        !mz_zip_writer_finalize_archive(&zip) ||
        !mz_zip_writer_end(&zip)) {
        return 0;
    }
    return 1;
}

MobiKitResult mobi_kit_convert_to_epub(
    const char *input_path,
    const char *output_path,
    char *error_message,
    size_t error_capacity
) {
    if (input_path == NULL || output_path == NULL) {
        set_error(error_message, error_capacity, "Missing file path");
        return MOBIKIT_INVALID_FILE;
    }
    MOBIData *mobi = mobi_init();
    if (mobi == NULL) {
        set_error(error_message, error_capacity, "Unable to allocate libmobi parser");
        return MOBIKIT_INVALID_FILE;
    }
    MOBI_RET result = mobi_load_filename(mobi, input_path);
    if (result != MOBI_SUCCESS) {
        MobiKitResult mapped = (result == MOBI_FILE_ENCRYPTED || mobi_is_encrypted(mobi))
            ? MOBIKIT_DRM_PROTECTED : MOBIKIT_INVALID_FILE;
        set_error(error_message, error_capacity, "libmobi rejected the publication");
        mobi_free(mobi);
        return mapped;
    }
    if (mobi_is_encrypted(mobi)) {
        set_error(error_message, error_capacity, "Protected Kindle publication");
        mobi_free(mobi);
        return MOBIKIT_DRM_PROTECTED;
    }
    if (mobi_is_replica(mobi)) {
        set_error(error_message, error_capacity, "Print Replica is not supported");
        mobi_free(mobi);
        return MOBIKIT_UNSUPPORTED;
    }
    MOBIRawml *rawml = mobi_init_rawml(mobi);
    if (rawml == NULL) {
        set_error(error_message, error_capacity, "Unable to allocate conversion model");
        mobi_free(mobi);
        return MOBIKIT_INVALID_FILE;
    }
    result = mobi_parse_rawml(rawml, mobi);
    if (result != MOBI_SUCCESS) {
        set_error(error_message, error_capacity, "libmobi could not reconstruct the publication");
        mobi_free_rawml(rawml);
        mobi_free(mobi);
        return MOBIKIT_INVALID_FILE;
    }
    int wrote = create_epub(rawml, output_path);
    mobi_free_rawml(rawml);
    mobi_free(mobi);
    if (!wrote) {
        set_error(error_message, error_capacity, "Unable to write EPUB");
        return MOBIKIT_WRITE_FAILED;
    }
    return MOBIKIT_SUCCESS;
}

const char *mobi_kit_libmobi_revision(void) {
    return "85dcfe803fc2a21020ddcf15c3eb66b93d388add";
}
