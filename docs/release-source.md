# App release source

The app release checkout is `/Users/tomoyatsukada/-manga-lounge-membership-app`.
The ChatGPT project copy is a separate checkout and previously held the native member-request changes that were missing from build 63.

## Build 63 incident

Build 63 (1.4.3) contained Events updates but omitted the approved Manga Requests and Suggestions implementation. The Settings rows, native forms, search-result request entry, request detail page and notification routing have now been restored into the release checkout. This source correction does not change an already distributed binary. A replacement build is required.

The two copies were compared across `lib`, `ios/Runner`, and `android/app/src`. Remaining functional differences are the newer Event ticket-link flow and approved event-detail design, corrected Events repository import, APNs registration fix, and newer token-registration behavior in the release checkout. These are retained. The theme difference is only a comment.

## Release preparation

Use this checkout for app changes and builds. Reconcile changes made in any other checkout here before a release. Record the Git revision and all uncommitted files in the release record, including newly added feature files. Keep the approved feature inventory with the record: Events, Manga Requests, Suggestions, empty-result manga request action, request status notification routing, APNs/FCM registration, membership and guest passes. A successful compiler build alone does not establish that the approved feature inventory is present.

Use the pinned FVM toolchain. Keep backend and scanner repositories separate from the app release checkout and record any backend dependency of the release.

## Replacement release 1.4.4 (64)

The published 1.4.3 (63) is superseded by 1.4.4 (64). All app changes and restored request files are recorded in Git before building. The iOS artifact uses this checkout, version 1.4.4 and build number 64. Build 64 was first distributed through TestFlight. Tomoya then approved App Store and Google Play production submission. iOS 1.4.4 (64) is submitted for review with automatic release enabled; Android 1.4.4 (64) is built from the same canonical checkout. Store notes: Restores Manga Requests and Suggestions for Pro members, including requesting unavailable manga from search and opening request updates from notifications.

## Security update 1.4.5 (65) — source prepared, not released

Canonical source now prepares server-owned registration, restricted profile updates, SMS-verified server erasure and subscription cancellation guidance. The matching backend functions are in this repository. No binaries or store submissions were created during the October 6 protection stage. Keep registration/erasure server-only cutover disabled until the new backend is deployed and the app is publicly available. See `docs/member-lifecycle-security.md` for the rollout gate, tests and remaining release requirements.

The October 6 name-edit regression is corrected in this release source: send only fields edited in the form and omit unchanged values in the data source. Timestamp-bearing profiles are covered by tests. No production rules were relaxed; the distributed build remains affected until this source is built and released.
