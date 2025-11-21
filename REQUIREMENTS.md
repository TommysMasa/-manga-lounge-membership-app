# Manga Lounge - Requirements Specification

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technical Stack](#technical-stack)
3. [Functional Requirements](#functional-requirements)
4. [Database Design](#database-design)
5. [Security Requirements](#security-requirements)
6. [Non-Functional Requirements](#non-functional-requirements)
7. [Development Scope](#development-scope)
8. [Future Enhancements](#future-enhancements)

---

## Project Overview

### Purpose
Manga Lounge membership mobile application for iOS and Android platforms. Users can register with phone number authentication, manage their profile, and display a QR code for entry/exit management.

### Target Platforms
- iOS
- Android

### Language
- English (UI/UX)

### Key Features
- Phone number authentication (SMS verification)
- User registration and profile management
- QR code generation for membership identification
- Entry/Exit status tracking (integrated with staff system)

---

## Technical Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI Components**: Material Design

### Backend
- **Authentication**: Firebase Authentication (Phone Auth)
- **Database**: Cloud Firestore
- **Hosting**: Firebase Hosting (optional for web version)

### Development Tools
- Flutter SDK 3.0+
- Dart 3.0+
- Firebase CLI
- Android Studio / VS Code

---

## Functional Requirements

### 1. Authentication Flow

#### 1.1 Splash Screen (Welcome Screen)
**File Reference**: `IMG_4989.PNG`

**UI Components**:
- Manga Lounge logo (centered)
- "Continue with phone" button
- Information banner: "Children under 13 may enter only with an adult parent or guardian."
- "Change Phone Number" link

**Functionality**:
- Display on app launch
- Navigate to Phone Input Screen on button tap
- Check existing authentication state (auto-login if already authenticated)

---

#### 1.2 Phone Input Screen
**File Reference**: `IMG_4990.PNG`

**UI Components**:
- Page title: "My number is"
- Subtitle: "We'll send a verification code to this number"
- Country code selector (default: +1)
- Phone number input field
- Terms of Service and Privacy Policy links
- "Continue" button

**Validation Rules**:
- Phone number must be valid format
- Required field

**Functionality**:
- Send SMS verification code to entered phone number
- Navigate to OTP Verification Screen
- Display error if phone number is invalid or SMS fails

---

#### 1.3 OTP Verification Screen
**File Reference**: `IMG_4991.PNG`

**UI Components**:
- Page title: "Verify your number"
- Subtitle: "Enter the code we've sent by text to [phone_number]"
- "Change number" link
- 6-digit PIN code input fields
- Timer: "This code should arrive within 22s"
- Auto-advance arrow button

**Validation Rules**:
- Must be exactly 6 digits
- Auto-submit when all 6 digits are entered

**Functionality**:
- Verify OTP code with Firebase Authentication
- On success: Check if user profile exists in Firestore
  - If NO → Navigate to Registration Screen
  - If YES → Navigate to Home Screen
- On failure: Display error message
- Allow resend code after timer expires

---

### 2. Registration Flow

#### 2.1 Registration Screen (Complete Your Profile)
**File Reference**: `IMG_4992.PNG`

**UI Components**:
- Page title: "Manga Lounge"
- Subtitle: "Complete Your Profile"
- Back button

**Personal Information Section**:
- First Name (text input)
- Last Name (text input)
- Email Address (text input)

**Date of Birth Section**:
- Month (dropdown/picker)
- Day (dropdown/picker)
- Year (dropdown/picker)

**Additional Information Section**:
- Gender (dropdown: Male/Female/Other/Prefer not to say)
- Phone Number (read-only, pre-filled from authentication)

**Validation Rules**:
- First Name: Required, min 1 character
- Last Name: Required, min 1 character
- Email: Required, valid email format
- Date of Birth: Required, user must be 13+ years old
- Gender: Required

**Functionality**:
- Save user profile to Firestore (`users` collection)
- Set initial values:
  - status: "checked_out"
  - entryTime: null
  - createdAt: current timestamp
  - updatedAt: current timestamp
- Navigate to Home Screen on successful registration

---

### 3. Home Screen

#### 3.1 Home Screen (Main Dashboard)
**File Reference**: `IMG_4993.PNG`

**UI Components**:
- Manga Lounge logo (top left)
- Logout button (top right, icon)
- Welcome message: "Welcome back, [First Name] [Last Name]"

**Membership Card**:
- QR code icon
- Title: "Membership"
- Subtitle: "Show your QR code"
- Arrow button → Navigate to QR Code Screen

**Settings Card**:
- Settings icon
- Title: "Settings"
- Subtitle: "Manage your account"
- Arrow button → Navigate to Settings Screen

**Status Display** (Bottom section):
- Status icon + "Status: [Checked In/Checked Out]"
- Clock icon + "Entry Time: [time or '-']"

**Functionality**:
- Fetch user data from Firestore on load
- Display real-time status updates (Firestore listeners)
- Navigate to respective screens on card tap

---

### 4. Membership QR Code

#### 4.1 QR Code Display Screen
**File Reference**: `IMG_4994.PNG`

**UI Components**:
- Back button
- Page title: "Manga Lounge"
- Subtitle: "Membership Card"
- User avatar icon (placeholder)
- User's name: "[First Name] [Last Name]'s Membership Card"
- QR code (large, centered)
- Status display: "Status: [Checked In/Checked Out]"
- Entry Time display: "Entry Time: [time or '-']"

**QR Code Data**:
- Contains: User's Firebase UID
- Format: Plain text string
- Size: 250x250 pixels

**Functionality**:
- Generate QR code from Firebase UID
- Real-time status updates via Firestore listener
- Staff can scan this QR code to check user in/out

---

### 5. Settings & Profile Management

#### 5.1 Settings Screen
**File Reference**: `IMG_4995.PNG`

**UI Components**:
- Back button
- Page title: "Settings"

**Menu Items**:
1. Profile → Navigate to Profile Edit Screen
2. Contact → Navigate to Contact Screen
3. Privacy Policy → Open Privacy Policy URL
4. Terms & Conditions → Open Terms & Conditions URL

**Functionality**:
- Navigate to respective screens
- Open external URLs for Privacy Policy and Terms

---

#### 5.2 Profile Edit Screen

**UI Components**:
- Same layout as Registration Screen
- Pre-filled with current user data
- Phone Number field is READ-ONLY (cannot be edited)

**Editable Fields**:
- First Name
- Last Name
- Email Address
- Date of Birth (Month, Day, Year)
- Gender

**Validation Rules**:
- Same as Registration Screen
- Phone number cannot be changed

**Functionality**:
- Load current user data from Firestore
- Update user document in Firestore
- Update `updatedAt` timestamp
- Show success message on save
- Navigate back to Settings Screen

---

#### 5.3 Contact Screen

**UI Components**:
- Contact information display
- Email: [support email]
- Phone: [support phone]
- Address: [physical address]

**Functionality**:
- Display contact information
- Optional: Allow users to send email or call directly

---

#### 5.4 Privacy Policy Screen

**Functionality**:
- Open Privacy Policy URL in external browser
- OR display webview with Privacy Policy content

---

#### 5.5 Terms & Conditions Screen

**Functionality**:
- Open Terms & Conditions URL in external browser
- OR display webview with Terms content

---

### 6. Logout

**Functionality**:
- Sign out from Firebase Authentication
- Clear local cache (SharedPreferences)
- Navigate to Splash Screen

---

## Database Design

### Firestore Collections

#### Collection: `users`

**Document ID**: Firebase Authentication UID

**Schema**:

```javascript
{
  // Personal Information
  "firstName": "John",              // string, required
  "lastName": "Doe",                // string, required
  "email": "john.doe@example.com",  // string, required, validated
  "gender": "male",                 // string, enum: "male" | "female" | "other" | "prefer_not_to_say"
  "dateOfBirth": Timestamp,         // Timestamp, required
  "phoneNumber": "+11234567890",    // string, E.164 format, required, read-only

  // Entry/Exit Management (Updated by Staff System)
  "status": "checked_out",          // string, enum: "checked_in" | "checked_out"
  "entryTime": null,                // Timestamp | null (null when checked out)
  "lastCheckInTime": Timestamp,     // Timestamp, last check-in time
  "lastCheckOutTime": Timestamp,    // Timestamp, last check-out time
  "totalVisits": 0,                 // number, total check-in count

  // Metadata
  "createdAt": Timestamp,           // Timestamp, auto-generated
  "updatedAt": Timestamp,           // Timestamp, auto-updated
  "isActive": true                  // boolean, account status
}
```

**Indexes**:
- `phoneNumber` (for quick lookup)
- `status` (for staff system filtering)
- `createdAt` (for sorting)

---

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function: Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper function: Check if user is the owner
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Helper function: Check if user is staff (Custom Claims)
    function isStaff() {
      return request.auth.token.isStaff == true;
    }

    // Users collection
    match /users/{userId} {
      // Allow read if authenticated and owner
      allow read: if isAuthenticated() && isOwner(userId);

      // Allow create if authenticated and owner
      allow create: if isAuthenticated() &&
                       isOwner(userId) &&
                       request.resource.data.phoneNumber is string &&
                       request.resource.data.firstName is string &&
                       request.resource.data.lastName is string &&
                       request.resource.data.email is string;

      // Allow update if authenticated and owner
      // Phone number cannot be changed
      allow update: if isAuthenticated() &&
                       isOwner(userId) &&
                       request.resource.data.phoneNumber == resource.data.phoneNumber;

      // Allow staff to update status fields only
      allow update: if isStaff() &&
                       request.resource.data.diff(resource.data).affectedKeys()
                         .hasOnly(['status', 'entryTime', 'lastCheckInTime',
                                   'lastCheckOutTime', 'totalVisits', 'updatedAt']);

      // Deny delete (only admins via Firebase Console)
      allow delete: if false;
    }
  }
}
```

---

## Security Requirements

### Authentication
1. **Phone Number Authentication**
   - Use Firebase Authentication Phone Auth
   - Enable reCAPTCHA verification
   - Implement rate limiting for SMS sends (Firebase default: 5 per hour)

2. **Session Management**
   - Firebase handles token refresh automatically
   - Store authentication state locally using SharedPreferences
   - Implement automatic logout after 30 days of inactivity (optional)

### Data Privacy
1. **Personal Information Protection**
   - User data encrypted at rest (Firebase default)
   - Data in transit encrypted via HTTPS
   - Firestore Security Rules enforce access control

2. **QR Code Security**
   - QR code contains only Firebase UID (no personal information)
   - UID is not guessable or enumerable
   - Staff system validates UID against Firestore

### Compliance
1. **Age Verification**
   - Users must be 13+ years old
   - Date of birth validation during registration
   - Display warning: "Children under 13 may enter only with an adult parent or guardian."

2. **Terms & Privacy**
   - Users must agree to Terms of Service and Privacy Policy
   - Links accessible from authentication and settings screens

---

## Non-Functional Requirements

### Performance
- App launch time: < 3 seconds
- Screen transitions: < 500ms
- QR code generation: < 1 second
- Firestore queries: < 2 seconds

### Scalability
- Support 10,000+ concurrent users
- Firestore automatically scales

### Reliability
- 99.9% uptime (Firebase SLA)
- Offline support for viewing cached user data
- Graceful error handling with user-friendly messages

### Usability
- Intuitive UI following Material Design guidelines
- Support for iOS and Android native behaviors
- Accessibility: Screen reader support, minimum touch target size (44x44 dp)

### Maintainability
- Clean code architecture (MVVM pattern)
- Comprehensive error logging
- Code documentation

---

## Development Scope

### Phase 1: User Mobile App (Current Scope)
**Included**:
- Phone number authentication
- User registration and profile management
- QR code display
- Settings screens
- Firebase backend setup
- iOS and Android builds

**Excluded**:
- Staff system (QR code scanning, check-in/out management)
- Web version
- Push notifications
- Analytics

**Estimated Timeline**: 4-6 weeks
- Week 1: Project setup, Firebase configuration, authentication flow
- Week 2: Registration, home screen, QR code display
- Week 3: Settings, profile edit, UI polish
- Week 4: Testing, bug fixes, deployment preparation

---

## Future Enhancements

### Phase 2: Staff System
- QR code scanner application (Web or Mobile)
- User check-in/check-out management
- User list and search functionality
- Visit history tracking
- Analytics dashboard

### Phase 3: Additional Features
- Push notifications for promotions
- Loyalty program / points system
- Visit history for users
- Multi-language support (Japanese, etc.)
- Dark mode support
- Profile photo upload
- Password reset via email

### Phase 4: Advanced Features
- Integration with payment systems
- Reservation system
- Social features (friends, sharing)
- In-app messaging
- Admin panel for user management

---

## Appendix

### Flutter Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0

  # State Management
  provider: ^6.1.1

  # UI
  qr_flutter: ^4.1.0
  intl_phone_field: ^3.2.0
  pin_code_fields: ^8.0.1
  flutter_spinkit: ^5.2.0

  # Utilities
  go_router: ^13.0.0
  intl: ^0.18.1
  form_field_validator: ^1.1.0
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.2
```

### Project Structure

```
manga_lounge/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── firebase_config.dart
│   │   └── router.dart
│   ├── models/
│   │   └── user_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── user_provider.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── firestore_service.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── phone_auth/
│   │   ├── registration/
│   │   ├── home/
│   │   ├── membership/
│   │   └── settings/
│   ├── widgets/
│   └── utils/
├── assets/
│   └── images/
├── pubspec.yaml
└── README.md
```

### Screen Flow Diagram

```
Splash Screen
    ↓
Phone Input Screen
    ↓
OTP Verification Screen
    ↓
    ├─ New User → Registration Screen → Home Screen
    └─ Existing User → Home Screen
                         ↓
                ├─ Membership → QR Code Screen
                └─ Settings → Settings Screen
                               ↓
                      ├─ Profile → Edit Profile Screen
                      ├─ Contact → Contact Screen
                      ├─ Privacy Policy → External URL
                      └─ Terms & Conditions → External URL
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-17 | Initial | Complete requirements specification |

---

**Document Status**: Draft
**Last Updated**: 2025-11-17
**Next Review**: Before Phase 1 Development Start
