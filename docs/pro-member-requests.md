# Native member requests and arrival notifications

Settings: Manga Requests and Suggestions appear above Edit Profile, with blue
icons and navy/gold PRO badges. Only Pro members see these two entries.
Manga search: when Libib completes a first-page search with its explicit
“No items found with this query!” response, Pro members see a compact
“Request this manga” action directly below Libib's message. The original
catalog result remains visible; the request action uses an orange pill.
The submitted search query prefills the native form. Empty/loading/error states
do not enable the request button. Searches are serialized to avoid stale results.

Pro status controls button visibility only, as requested. Neither the form nor
the submit callable rechecks a subscription. The callable still requires a
signed-in, non-banned profile and saves its authenticated UID. Tally is not used.

## Storage and delivery

`submitMemberRequest` saves `memberRequests/{uid}_{submissionId}` with type,
title, volumes, details, source, UID, pending status and server timestamps.
The client retains submission ID on a failed attempt; duplicate writes are avoided.
Firestore clients may read their own requests, and staff may read the inbox;
all writes use the server callables.

The entry-scanner has an English Member Requests screen with Pending, Ordered,
Arrived and Cancelled states. Staff can move a pending request to Ordered,
Arrived or Cancelled, then move an Ordered request to Arrived or Cancelled.
Each change requires explicit confirmation and creates an English notification.
Ordered tells the member another notification will follow on arrival. Cancelled
requires an English staff comment, which is included in the push and detail
screen. `updateMemberRequestStatus` verifies staff identity and atomically
updates the status with an outbox job. Duplicate calls do not resend. Existing
`completed` requests display as Arrived, and the old `completeMemberRequest`
callable remains available for older scanner clients.

`notifyMemberRequestCompleted` uses the existing user's FCM token. It tracks
sent/failed/no_device, retries transient errors, and suppresses previously sent
jobs and concurrent workers with a lease. Staff can retry after an invalid or
missing device token. New attempts supersede older jobs. FCM accepted delivery
is shown as “通知送信済み”; it is not proof the device displayed or read it.
Like other external delivery systems, a crash after FCM accepts but before the
sent state is recorded can cause redelivery. Notification collapse/tag IDs reduce
repeat displays but do not guarantee exactly-once delivery.

Notification taps open `/requests/{requestId}` after authentication, including
cold start. That screen reads the saved request, current status and staff reply
under Firestore permissions. A success-screen button lets the member enable
notifications. No staff action or live push was performed during tests.

## Release coordination

The request functions are deployed to `simpleapp-5c1c6`. Future function edits
should target only the request functions (not a blanket functions deployment):

```
firebase deploy --only functions:submitMemberRequest,functions:updateMemberRequestStatus,functions:completeMemberRequest,functions:notifyMemberRequestCompleted
```

The Firebase project is shared. The live Firestore rules were updated manually
from the then-current rules with the memberRequests read rule. Outbox documents
remain client-inaccessible. The local Entry-Scanner checkout was updated on the
store Mac; iOS build 58 includes the new status detail screen.

Tests cover native form validation/navigation/retry, Pro-only entry visibility,
requester identity, staff authorization, notification jobs/retries, and the Libib
bridge. Real-device push and live Libib WebView end-to-end verification still
require a deployed backend and test accounts. The Libib bridge uses inspected
public `/js/u/search.js` behavior and must be revisited if Libib changes its response format.
