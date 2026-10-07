# Member lifecycle security — staged rollout, October 6, 2026

Canonical repositories:
- App and membership backend: `/Users/tomoyatsukada/-manga-lounge-membership-app`.
- Production Firestore rules and scanner: `/Users/tomoyatsukada/Github/entry-scanner`.

Tomoya chose to deploy member business-field protection first, preserving the released app's registration and account erasure. Registration/erasure become server-only after the new app is publicly available. The app source is prepared as 1.4.5 (65); no store submission or backend deployment is performed by this change.

## First production stage

Scanner rules restrict a member's updates to profile and push-token fields. UID, status and lastEntryTime can be serialized by older app versions only when their effective values are unchanged. Membership age, staff/ban flags, visit counts, benefits and nested business flags cannot be changed or removed by a member. Reads and staff operations remain available. Initial legacy registration permits only the original profile fields and checked-out defaults.

Legacy initial createdAt is still client supplied. Legacy self-erasure and deletionStats writes are deliberately retained until cutover. Item 1 is therefore partially complete, not fully complete.

`config/memberLifecycle.serverOnly` defaults to false when absent. Only Admin SDK/console can write it. Do not set it to true until the backend is deployed, app 65 is available, and store/member checks pass. Setting it true prevents older apps from registering or erasing accounts.

## Prepared backend and app

- `createMemberProfile`: phone-backed Auth identity, strict personal-field input, server creation time/status, idempotent creation, synchronous persistent ban check.
- `deleteMyAccount`: own authenticated account only, recent/revocation-aware identity check before writes, explicit confirmation, rejects owner/store/staff and active visits. Disabled until serverOnly cutover.
- `accountDeletionJobs`: server-only hashed UID key; durable lease, retry every 15 minutes, statistics counted once. Completed jobs erase UID, email, phone hash and anonymous-history association; retain completion time/attempts and the irreversible hashed tombstone to prevent recreation under the same UID.
- Profiles/subcollections, subscriptions, searches, requests/notifications, attributable surveys, coupon/reminder/waitlist data and related references are erased. Visit/merchandise/guest-pass/event finance history uses a business-field projection and an unlinked random history identifier. Other members' identities and guest-pass quotas remain intact.
- Banned phone registry persists for ban enforcement. Its existing hash algorithm remains compatible; secret migration is separate work.
- Delayed RevenueCat notifications skip retired UID jobs; a subscription cleanup trigger provides additional protection.
- App requests registration/erasure through us-central1 callables; profile updates write only editable fields. Withdrawal verifies an SMS code and explains retained history and separate subscription cancellation.

## Remaining release checks

1. Deploy these membership backend functions from this recorded repository, verify runtime identity can delete synthetic Auth users, and configure error alerts using the existing verified notification channel.
2. Build with `.fvm/flutter_sdk` (Flutter 3.35.7) from a clean recorded app source; record commit, version, artifact hashes and post-build source comparison. No new binaries are built in this stage.
3. Test registration, SMS reauthentication, erasure and subscription management on actual iOS/Android devices using synthetic accounts. Exercise a server-only cutover in a safe test environment.
4. Submit/release app 1.4.5 (65), then enable serverOnly and verify live rule source and normal store operations.
5. Coordinate erasure with external systems (RevenueCat customer records, Square retained financial data, Google Forms/Sheets survey sources, existing exports) and asynchronous external importers. Those external records are not erased by this Firestore job. Existing backups expire under their retention policy; a restore must replay erasure tombstones/jobs before use. Existing logs follow their separate retention policy.

## Validation

Dedicated localhost Firestore emulator project `demo-member-lifecycle` at port 18080 only; no production member or payment mutation in tests. Backend tests cover forged privileges, stale/revoked identity, protected accounts, active visits, anonymous nested financial projections, resumable Auth failure, persistent ban and once-only deletion counts. Webhook tests cover retired and normal renewals. App tests verify restricted payloads and own-account erasure; 20 cases passed with the pinned Flutter toolchain. Scanner rule tests exercise pre-cutover compatibility and post-cutover denial, viewing/profile edits, staff check-in/checkout/goods/guest operations and removal attacks.

## Profile edit regression reported October 6

The released app sends User.toJson() for a name edit. TimestampConverter reads a Firestore Timestamp into a local DateTime, then writes an ISO string. Protecting lastEntryTime with strict equality rejects that legitimate edit after a visit. The first rule compatibility test covered null entry times and missed this type conversion. A dedicated scanner emulator test now reproduces permission-denied with the released payload and verifies that a name-only payload succeeds without modifying the stored entry timestamp.

The app now passes only fields edited since the form opened, and the data source additionally omits values already equal to the current document. Writes always exclude UID, membership age, visit state, entry time and business flags. Unchanged submissions do not write updatedAt. The form resets its change baseline after a successful save, and empty ZIP input can clear a previously entered ZIP. App/form tests total 20; analysis passes on the pinned Flutter SDK.

This is a source fix, not a delivered binary. The current public app can still fail profile edits containing timestamp reserialization until the repaired version is distributed. Production rules have not been relaxed or redeployed for this correction. Deployment of the prepared lifecycle backend, app build/device checks and store distribution are still pending.

## TestFlight 65 compatibility

Tomoya authorized TestFlight upload on October 6. The app reads `config/memberLifecycle.serverOnly` from the server. While absent/false it preserves released-app registration and erasure, with SMS reauthentication before erasure. When true, it uses the prepared server callables. The rollout document is readable by signed-in users and writable only on the server. TestFlight does not enable cutover or publish to the App Store. The confirmation text describes retained business records without promising that legacy erasure has performed the pending server anonymization.

## October 7 TestFlight preview

Build 1.4.6 (67) uses MEMBER_LIFECYCLE_PREVIEW=true, so it calls the server independently of the global serverOnly switch. Production 1.4.5 (66) and older apps keep the existing path. The new callables use a keyless member-lifecycle runtime with only Firebase Auth user get/delete, Firestore data access and log writing. previewEnabled permits authenticated own-account erasure before global cutover; owner/shop/staff and active visits remain protected. It does not revoke old client permissions. A durable accepted erasure signs the app out even if background retry is needed. Server-only cutover and public release of the preview are pending Tomoya acceptance. No GitHub push until that acceptance.
