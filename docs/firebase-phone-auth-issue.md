# Firebase Phone Authentication Issue on iOS

## Error Message

```
[firebase_auth/recaptcha-sdk-not-linked] The reCAPTCHA SDK is not linked to your app.
See https://cloud.google.com/recaptcha-enterprise/docs/instrument-ios-apps
```

**Location**: `lib/features/auth/data/datasources/auth_datasource.dart:66` (inside `verificationFailed` callback)

## Current Configuration State

### GoogleService-Info.plist
- **BUNDLE_ID**: `com.mangalounge.memberapp`
- **REVERSED_CLIENT_ID**: `com.googleusercontent.apps.640646199364-at26bdjg6u5dt43dt5jhf1qeerqq14en`
- **GOOGLE_APP_ID**: `1:640646199364:ios:4667a78a84127c29fca411`
- **PROJECT_ID**: `simpleapp-5c1c6`

### Info.plist
- **URL Scheme**: `com.googleusercontent.apps.640646199364-at26bdjg6u5dt43dt5jhf1qeerqq14en`
- **UIBackgroundModes**: `remote-notification` (enabled)

### Firebase Console (Cloud Messaging)
- APNs Authentication Key configured for `manga_lounge (ios)` (`com.mangalounge.memberapp`)
- Key ID: `YWFPADQ6TM`
- Team ID: `HAT88XKLX2`

### Apple Developer Portal
- Push Notifications capability: Enabled for the App ID

## What Was Changed

1. Replaced `GoogleService-Info.plist` - previous file had wrong BUNDLE_ID (`com.tomy.simpleiosapp-com.tomy.simpleiosapp-`)
2. Updated URL scheme in `Info.plist` to match new REVERSED_CLIENT_ID
3. Added `UIBackgroundModes` with `remote-notification` to `Info.plist`

## What Needs Verification

1. Is **Push Notifications** capability added in Xcode (Signing & Capabilities tab)?
2. Is the app being tested on a **real device**? (Phone auth does not work on iOS Simulator)
3. Is APNs actually working? (Silent push notification should be received before SMS is sent)
4. Is there a provisioning profile mismatch after enabling Push Notifications?

## Relevant Files

- `ios/Runner/GoogleService-Info.plist`
- `ios/Runner/Info.plist`
- `ios/Runner/Runner.entitlements`
- `lib/features/auth/data/datasources/auth_datasource.dart`

## References

- [GitHub Issue #17557 - recaptcha-sdk-not-linked](https://github.com/firebase/flutterfire/issues/17557)
- [FlutterFire Phone Authentication Docs](https://firebase.flutter.dev/docs/auth/phone/)
- [Zenn Article (Japanese)](https://zenn.dev/senkyaku/articles/e49b50dc07bc8b)
