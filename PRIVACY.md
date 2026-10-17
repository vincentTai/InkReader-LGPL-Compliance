# Readune Privacy Policy

Updated: 2026-10-17

Readune (bundle identifier com.thinksview.inkreader, previously named InkReader /
Endpaper during development) is a local-first ebook reader. The developer does
not collect, receive, sell or share your books, search queries or reading history.
The app contains no advertising, analytics or tracking SDKs.

## Reading and importing

Imported files, converted reading copies, covers, local search indexes and reading
statistics are stored on your device. File parsing, format conversion and text
indexing occur on the device. The Share extension temporarily stages files in the
app's private App Group inbox for the main app to import. Readune does not run a
server that receives these files or search queries.

## Optional Apple iCloud services

When available, Apple's iCloud key-value storage synchronizes reading positions,
bookmarks and per-book preferences using a file fingerprint. This does not upload
the book itself. Separately, Readune Plus offers an optional library-sync setting:
when enabled, original book files and library metadata are copied to your own
iCloud Drive so other devices can import them. These files consume your iCloud
storage. The developer does not receive a copy or have access to your iCloud.

Turning library sync off stops new library sync passes; it does not delete existing
cloud copies or disable the separate progress/preferences service. Deleting a book
while library sync is active removes its iCloud library copy and propagates the
deletion to your other devices. Apple processes iCloud data under its own terms
and privacy policy. Manage iCloud access and storage through your Apple settings.

## Read Aloud and natural voices

Read Aloud can use the system voices provided by iOS, or optional natural voices
that run entirely on your device. Text being read and the generated audio never
leave the device, and Readune does not operate a voice service.

The natural voices are open voice models that you can choose to download from the
Read Aloud player (roughly 130–145 MB per pack). The files are requested from
public model hosts — Hugging Face (huggingface.co, or its mirror hf-mirror.com) and
GitHub — and, if those fail or are too slow, from a copy the developer keeps on
Cloudflare R2 at readune-assets.thinksview.com. As with any download, these hosts
receive the ordinary technical details of the request, such as your IP address
and the app's user agent; the developer does not use Cloudflare's request data to
identify or track readers. No account, book content or reading data is sent with
these requests. Downloaded packs can be removed from the voice list at any time.

How many minutes of natural voice you have used, when your first unmetered days
began, and which version of a voice model's terms you accepted (where a model
requires it) are recorded on the device only. System voice availability and
downloads are managed by Apple.

## Sample books, offers and ratings

The sample books offered on an empty shelf are public-domain texts bundled with
the app and imported like any other file. The app decides when to show the Plus
offer or ask for an App Store rating from counts kept on the device (for example,
how many reading sessions you have had); nothing about this is sent to the
developer. Ratings are requested through Apple, which decides whether to show the
prompt.

## Purchases

Optional Plus purchases are handled by Apple's App Store. Readune checks verified
StoreKit transactions to determine access and stores entitlement state locally.
The developer does not receive payment card details. Manage subscriptions and
purchase history in your Apple Account settings.

## External links and deletion

Opening an external support, privacy, license or terms link uses your browser and
may contact the relevant website. Readune has no account to delete. You can remove
books inside the app and remove app-local data by uninstalling it; iCloud copies
must be managed separately as described above.

## Contact

Support: https://github.com/vincentTai/InkReader-LGPL-Compliance/issues
Do not post private book files, payment details or account credentials in public
support issues.
