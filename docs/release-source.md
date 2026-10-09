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

## Security update 1.4.5 — TestFlight verified, production release authorized

Canonical source now prepares server-owned registration, restricted profile updates, SMS-verified server erasure and subscription cancellation guidance. The matching backend functions are in this repository. No binaries or store submissions were created during the October 6 protection stage. Keep registration/erasure server-only cutover disabled until the new backend is deployed and the app is publicly available. See `docs/member-lifecycle-security.md` for the rollout gate, tests and remaining release requirements.

The October 6 name-edit regression is corrected in this release source: send only fields edited in the form and omit unchanged values in the data source. Timestamp-bearing profiles are covered by tests. No production rules were relaxed; the distributed build remains affected until this source is built and released.

TestFlight 65 upload was authorized on October 6. This build uses a read-only server rollout gate to retain existing registration/retirement until the server migration is enabled. It includes the delta-only profile fix and SMS verification before retirement. Tomoya subsequently confirmed TestFlight registration and retirement and authorized App Store and Google Play production release on October 6. See the build 66 production record below.

## Production release 1.4.5 (66)

On October 6, Tomoya confirmed registration and retirement in TestFlight 65 and requested iOS and Android production release. Build 65 is internal-only and cannot be submitted to App Review. Build 66 preserves the tested application source and changes only the build number for production submission. Keep the server-only lifecycle gate disabled until the backend migration and public rollout are confirmed separately.

Production submission completed on 2026-10-06: iOS 1.4.5 (66) is Waiting for Review, submission 3146d7f7-7f61-49ae-82bb-b0b3891e1a72, automatic release after approval. Android 66 (1.4.5) is Changes in review after passing quick checks, production full rollout, managed publishing off. Store approval and public availability are pending. Both artifacts were built from eb12ce5a8c67de4c601950c35fc1d1e8d372e250; application source stayed clean after builds. Backend lifecycle gate remains unchanged.

## Accepted local source — October 8 navigation fix

Tomoya verified the iPhone build from `235c452b7ef274265384835996206e2ab5d247a8` and accepted this checkout as the canonical version on October 8. It includes recovery from a deleted Firebase session on the registration screen and a bounded iOS tab-frame recovery after registration. Source tests passed and targeted static analysis found no issues. Hardware success is user-observed; no exact post-fix display timing is claimed.

The installed measurement artifact is 1.4.6 (70), profile mode, built with pinned Flutter 3.35.7 and `MEMBER_LIFECYCLE_PREVIEW=true`, `MEMBER_NAVIGATION_DIAGNOSTICS=true`. This is a local measurement artifact, distinct from previously uploaded TestFlight build 70. The diagnostics define is off by default; no diagnostic activation is required for the frame recovery. GitHub synchronization is authorized. TestFlight upload and a new public release are explicitly deferred. See `docs/member-home-repro-20261008.json`.
